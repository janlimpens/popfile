# Plan: Konfiguration & Bucket/Folder-Mapping Überarbeitung

## Problemanalyse

### 1. Proprietäres Config-Format ohne Encoding

`popfile.cfg` ist ein zeilenbasiertes `key value`-Format ohne jede Encoding-Spezifikation.
Werte werden als rohe Bytes gelesen und geschrieben — kein `:encoding(UTF-8)` Layer.
Was in Perl intern als UTF-8-String vorliegt (z.B. IMAP-Ordnername nach UTF-7-Dekodierung),
wird ohne `Encode::encode` auf die Platte geschrieben. Beim Zurücklesen fehlt `Encode::decode`.
Das funktioniert nur zufällig, solange alle Werte ASCII sind.

### 2. Fragile Serialisierung des Bucket-Folder-Mappings

Die Zuordnung Bucket↔IMAP-Folder wird als ein einzelner Config-Wert gespeichert:

```
imap_bucket_folder_mappings spam-->Junk-->ham-->INBOX.Archive-->
```

`split /-->/, $string` ergibt abwechselnd Bucket/Folder-Paare. Probleme:

- `-->` als Separator ist nicht escaped — ein Folder- oder Bucket-Name mit `-->` zerstört die Struktur
- Der gesamte Mapping-String wird bei jedem Zugriff geparst und bei jedem Schreibzugriff neu zusammengebaut
- Watched Folders nutzen dieselbe Technik (`imap_watched_folders`)

### 3. Mehrere unabhängige Lese-/Schreibpfade

| Pfad | Lesen | Schreiben | Encoding | Locking | Temp-File |
|------|-------|-----------|----------|---------|-----------|
| `Configuration::load_configuration()` | ✓ | | Keine | Kein | — |
| `Configuration::save_configuration()` | | ✓ | Keine | Kein | ✓ (.tmp → copy) |
| `script/popfile` `_cfg_value()` | ✓ | | Keine | Kein | — |
| `script/popfile` `do_config()` | ✓ | ✓ | Keine | Kein | Nein (direkt) |
| `docker-entrypoint.sh` | | ✓ | — | Kein | — |

Der CLI-Befehl `popfile config key=value` und der laufende Daemon greifen gleichzeitig
auf dieselbe Datei zu, ohne jegliche Koordination.

### 4. Keine klare Domäne für Bucket und Folder

- `Classifier::Bucket` ist ein generischer Property-Bag (`%props` Hash) statt typisierter Felder
- Es gibt keine Folder-Klasse — Folder sind ad-hoc Hashes in `Services::IMAP`
- Bucket-Namen existieren in drei unabhängigen Speicherorten: SQLite `buckets`-Tabelle,
  Config-String `bucket_folder_mappings`, und im Memory-Cache `$db_bucketid`
- Kein einheitlicher Typ erzwingt konsistentes Encoding

### 5. IMAP Modified UTF-7 nur halb implementiert

`Services::IMAP::Client::_imap_utf7_decode()` dekodiert Folder-Namen vom Server korrekt.
Aber es gibt **kein Re-Encoding zu Modified UTF-7** beim Senden von Befehlen an den Server.
Non-ASCII Folder-Namen in `SELECT`, `COPY`, `STATUS` etc. werden als rohe UTF-8-Bytes gesendet —
das ist eine RFC-Verletzung und funktioniert nur bei Servern, die UTF-8 tolerieren.

---

## Zielarchitektur

### Prinzipien

1. **Single Source of Truth** — Jeder Wert hat genau einen kanonischen Speicherort
2. **Single Read/Write Path** — Alle Zugriffe laufen über dasselbe Modul
3. **Explizites Encoding** — UTF-8 rein, UTF-8 raus, immer
4. **Atomare Schreibvorgänge** — Temp-File + Rename, mit Advisory Lock
5. **Typisierte Domänenobjekte** — Bucket und Folder als echte Klassen mit definierten Feldern

### Format: JSON

**Warum JSON:**
- `Cpanel::JSON::XS` ist bereits in den Dependencies
- Definiertes Encoding (UTF-8 per Spec)
- Kein Parsing-Code zu pflegen
- Strukturierte Daten (Nested Objects) statt flacher Key-Value
- Tooling überall verfügbar (jq, Browser, etc.)

**Warum nicht YAML/TOML:**
- YAML: Keine Dependency vorhanden, implizite Typkonvertierung (norway problem), komplexer Parser
- TOML: Keine Perl-Dependency vorhanden, weniger verbreitet im Perl-Ökosystem

### Ziel-Dateistruktur

`popfile.json`:

```json
{
  "version": 2,
  "global": {
    "message_cutoff": 100000,
    "msgdir": "messages/",
    "timeout": 60
  },
  "api": {
    "port": 0,
    "local": true,
    "locale": "de",
    "password": "ENC:...",
    "session_dividers": true
  },
  "config": {
    "piddir": "./",
    "pidcheck_interval": 5
  },
  "imap": {
    "hostname": "mail.example.com",
    "login": "alice",
    "password": "ENC:...",
    "watched_folders": ["INBOX"],
    "bucket_folder_mappings": {
      "spam": "Junk",
      "ham": "INBOX.Archive",
      "persönlich": "INBOX.Persönlich"
    }
  },
  "bayes": {
    "database": "popfile.db"
  }
}
```

Vorteile gegenüber dem alten Format:
- `bucket_folder_mappings` ist ein echtes JSON-Objekt — kein fragiler `-->` Separator
- `watched_folders` ist ein echtes Array
- Booleans sind Booleans, Zahlen sind Zahlen
- Verschachtelte Namespaces statt flacher `module_param`-Strings

---

## Umsetzungsplan

### Phase 0: Domänenobjekte (Prerequisite)

**Ziel:** Klare Typen für Bucket und Folder, die überall verwendet werden.

#### 0a. `Classifier::Bucket` modernisieren

Aktuell ein generischer Property-Bag. Umbauen zu typisierten Feldern:

```perl
class Classifier::Bucket;

field $id :param = undef;
field $name :param :reader;
field $color :param :reader :writer = 'black';
field $count :param :reader :writer = 0;
field $pseudo :param :reader = 0;
field $prior :reader :writer = 0;
```

`new_from_db($row)` wird ein normaler Konstruktor mit benannten Parametern.
Alle Nutzer von `get_property('name')` etc. migrieren zu `$bucket->name()`.

#### 0b. `Services::IMAP::Folder` einführen

Neue Value-Klasse für IMAP-Folder:

```perl
class Services::IMAP::Folder;

field $name :param :reader;         # Interner Name (UTF-8)
field $imap_name :param :reader;    # IMAP Modified UTF-7 Name
field $watched :param :reader :writer = 0;
field $output_bucket :param :reader :writer = undef;
```

Die Klasse kapselt die UTF-7 ↔ UTF-8 Konvertierung:

```perl
method from_imap_name ($encoded) {  # class method
    my $decoded = _imap_utf7_decode($encoded);
    return Services::IMAP::Folder->new(
        name => $decoded,
        imap_name => $encoded,
    )
}

method to_imap_name () {
    return $imap_name // _imap_utf7_encode($name)
}
```

So ist an **einer** Stelle definiert, wie zwischen internem UTF-8-Namen und
IMAP-Wire-Format konvertiert wird.

#### 0c. Tests

- Unit-Tests für `Bucket` Konstruktor und Accessors
- Unit-Tests für `Folder` mit UTF-7 Round-Trip (ASCII, Umlaute, CJK)
- Die existierenden Unicode-Bucket-Tests in `t/services-classifier.t` erweitern

### Phase 1: `POPFile::Configuration` auf JSON umstellen

#### 1a. Neues Modul `POPFile::ConfigFile`

Separates, zustandsloses Modul nur für Datei-I/O:

```perl
class POPFile::ConfigFile;

use Cpanel::JSON::XS;
use Fcntl qw(:flock);
use Path::Tiny;

method load ($path) { ... }   # → HashRef
method save ($path, $data) { ... }
```

**Lesen:**
- `open` mit `:encoding(UTF-8)`
- `flock(LOCK_SH)` (shared lock)
- `Cpanel::JSON::XS->new->utf8->decode($content)`
- Lock release bei close

**Schreiben:**
- In Temp-File `$path.tmp` schreiben
- `flock(LOCK_EX)` (exclusive lock) auf Zieldatei
- `Cpanel::JSON::XS->new->utf8->pretty->canonical->encode($data)`
- `rename($tmp, $path)` — atomarer Ersatz auf POSIX
- `chmod 0600`
- Lock release

**Wichtig:** `rename` statt `File::Copy::copy` — `copy` ist nicht atomar,
`rename` innerhalb desselben Filesystems schon.

#### 1b. `POPFile::Configuration` refactoren

- `%configuration_parameters` bleibt als In-Memory-Store
- `load_configuration()` nutzt `POPFile::ConfigFile::load()`
- `save_configuration()` nutzt `POPFile::ConfigFile::save()`
- Die Verschlüsselung sensitiver Werte bleibt (`_encrypt_config` / `_decrypt_config`)
- Parameter-Registrierung (`parameter()`) bleibt unverändert
- **Neu:** `to_structured_hash()` — wandelt den flachen `module_param` Namespace
  in verschachtelte Struktur um und zurück

Interne API bleibt kompatibel: Module rufen weiterhin `$self->config('param', $value)` auf.
Nur die Persistenzschicht ändert sich.

#### 1c. Migration: Altes Format lesen, neues schreiben

`load_configuration()` prüft:
1. Existiert `popfile.json`? → Lade JSON
2. Existiert nur `popfile.cfg`? → Lade altes Format, schreibe sofort `popfile.json`, benenne `popfile.cfg` zu `popfile.cfg.bak` um

So ist die Migration automatisch und einmalig. Kein manueller Eingriff nötig.

#### 1d. `script/popfile` CLI vereinheitlichen

- `_cfg_value()` und `do_config()` nutzen `POPFile::ConfigFile` statt eigene Parser
- Die duplizierte Crypto-Logik entfällt
- Kein direktes File-I/O mehr außerhalb von `ConfigFile`

#### 1e. `docker-entrypoint.sh` anpassen

Initiale Config als JSON generieren statt als Key-Value-Paare.

#### 1f. Tests

- `t/config-file.t`: Round-Trip für `ConfigFile::load`/`save` (UTF-8, Sonderzeichen, leere Werte)
- `t/config-migration.t`: Altes Format → neues Format, inklusive verschlüsselter Werte
- `t/config-locking.t`: Zwei Prozesse greifen gleichzeitig zu — kein Data Loss
- `t/config-cli.t`: `do_config` gegen das neue Format

### Phase 2: Bucket-Folder-Mapping aus der Config in die DB verschieben

#### 2a. Neue DB-Tabellen

```sql
CREATE TABLE imap_folder_mappings (
    id INTEGER PRIMARY KEY,
    userid INTEGER NOT NULL REFERENCES users(id),
    bucket_name VARCHAR(255) NOT NULL,
    folder_name VARCHAR(255) NOT NULL,
    UNIQUE(userid, bucket_name)
);

CREATE TABLE imap_watched_folders (
    id INTEGER PRIMARY KEY,
    userid INTEGER NOT NULL REFERENCES users(id),
    folder_name VARCHAR(255) NOT NULL,
    UNIQUE(userid, folder_name)
);
```

**Warum in die DB statt in die JSON-Config?**

- Das Mapping ist **relationale Daten** (Bucket → Folder, pro User) — gehört in eine DB
- Gleichzeitiger Zugriff durch API-Server und IMAP-Worker ist über SQLite WAL-Mode sicher
- Kein Serialisierungsproblem mehr
- Die Config-Datei enthält dann nur noch echte Konfiguration (Hostnames, Ports, Flags)

#### 2b. `Services::IMAP` refactoren

- `folder_for_bucket()` liest aus der DB statt aus der Config
- `watched_folders()` liest aus der DB
- `build_folder_list()` baut `%folders` aus `Services::IMAP::Folder`-Objekten
- Config-Keys `imap_bucket_folder_mappings` und `imap_watched_folders` entfallen

#### 2c. Migration

Beim Start prüfen:
1. Config enthält noch `imap_bucket_folder_mappings`? → Parse, schreibe in DB-Tabellen, entferne aus Config
2. DB-Tabellen existieren bereits? → Nichts tun

#### 2d. API anpassen

`POPFile::API::Controller::IMAP::update_folders()` schreibt direkt in die DB statt über
`config('bucket_folder_mappings', ...)`.

#### 2e. Tests

- `t/imap-folder-mapping.t`: CRUD für Folder-Mappings in der DB
- `t/imap-migration.t`: Alte Config-Strings → DB-Migration
- `t/imap-folder-utf8.t`: Unicode-Folder-Namen Round-Trip (DB + IMAP Wire)

### Phase 3: IMAP UTF-7 Encoding fixen

#### 3a. `_imap_utf7_encode()` implementieren

Gegenstück zu `_imap_utf7_decode()` in `Services::IMAP::Client`.
Benutzt `Encode::encode('UTF-16BE', ...)` + Base64 + Modified-UTF-7-Regeln.

#### 3b. Alle IMAP-Befehle über `Folder::to_imap_name()` routen

`SELECT`, `STATUS`, `COPY`, `MOVE` etc. nutzen `$folder->to_imap_name()` statt den
rohen internen Namen. So ist die Encoding-Boundary klar definiert.

#### 3c. Tests

- `t/imap-utf7.t`: Encode/Decode Round-Trip für bekannte Testfälle (RFC 3501 Beispiele)
- Integration-Test mit realen Folder-Namen (Umlaute, Kyrillisch, CJK)

---

## Reihenfolge und Abhängigkeiten

```
Phase 0a (Bucket)  ──┐
Phase 0b (Folder)  ──┼── Phase 1 (JSON Config) ── Phase 2 (DB Mapping) ── Phase 3 (UTF-7)
Phase 0c (Tests)   ──┘
```

Phase 0 hat keine Abhängigkeiten und kann sofort beginnen.
Phase 1 hängt von Phase 0 ab (Folder-Typ für saubere Serialisierung).
Phase 2 hängt von Phase 1 ab (Config-Migration muss stehen).
Phase 3 kann parallel zu Phase 2 laufen, muss aber vor dem Merge von Phase 2 fertig sein
(damit IMAP-Befehle korrekt encodiert werden).

---

## Risiken und Mitigationen

| Risiko | Mitigation |
|--------|------------|
| Bestehende Installationen haben `popfile.cfg` | Automatische Migration in Phase 1c |
| CLI-Tools greifen während Migration zu | Advisory Lock in `ConfigFile` |
| Unicode-Bucket-Namen im DB-Schema | `sqlite_unicode => 1` ist bereits aktiv |
| IMAP-Server die kein UTF-8 tolerieren | Phase 3 fixt das — bis dahin Status quo |
| Externe Tools die `popfile.cfg` parsen | `popfile.cfg.bak` bleibt als Fallback, Doku anpassen |

---

## Nicht im Scope

- Wechsel des DB-Backends (bleibt SQLite)
- Änderung der Klassifikations-Logik
- UI-Refactoring (die API-Schicht abstrahiert die Änderungen)
- Multi-User-Support (bestehendes User-Modell bleibt)
