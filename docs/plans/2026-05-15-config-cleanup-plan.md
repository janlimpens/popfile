# Config Cleanup Plan

## Ziel-Architektur

```
config.json  ◀── write ──  ConfigFile (atomic: flock + temp + rename)
    │                            ▲
    │ load ONCE (startup)        │ API Controller (nutzt ConfigFile direkt)
    ▼                            │
Config singleton (FROZEN)        │
    │
    └── get(ns, key)  ◀── Role::Config (read-only handle)
                                 │
                                 └── alle Module (Bayes, IMAP, …)
```

**Regeln:**

- Config-Singleton hat **kein** `write()` — nach `load_file()` nie mehr verändert
- API Controller schreibt via `ConfigFile` → liest JSON, modifiziert, speichert atomar
- UI hält geschriebene Werte bis zum Neustart — `write → restart` ist der einzige Weg
- Loader handled free-port (api.port=0) beim ersten Start: Port finden → schreiben → neu starten
- Jedes Modul deklariert `%DEFAULTS` → Loader sammelt ein
- Module bekommen nur read-only handle via Role::Config: `$self->config->get('key')`
- Kein Modul sieht jemals das `Configuration`-Objekt

---

## Implementierung (strikt in Reihenfolge)

### Phase 1 — Fundament

| #     | Datei                         | Änderung                                                                                                                                                                                           |
| ----- | ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1** | `POPFile/Config.pm`           | Singleton mit nested `%store`. `load_defaults(\%defaults_by_ns)`, `load_file($path)`, `get($ns, $key)`. Kein `write()`, kein `namespace()`, keine `load()`-Methode die `Configuration` akzeptiert. |
| **2** | `POPFile/Role/Config.pm`      | `config()` returned read-only Handle mit NUR `get($key)`. Kein `write()`, kein `configuration()`. Kein `$module`-Parameter (cross-module reads über Handle-Factory oder weg).                      |
| **3** | `POPFile/Config/Namespace.pm` | Entfällt oder wird zu minimalem `Config::Handle` mit nur `get($key)`.                                                                                                                              |
| **4** | `POPFile/ConfigFile.pm`       | Prüfen ob `save()` atomic genug ist. Evtl. `modify_and_save($path, sub { ... })` als Convenience.                                                                                                  |

### Phase 2 — Loader

| #     | Datei               | Änderung                                                                                                                                                                                                                                                            |
| ----- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **5** | `POPFile/Loader.pm` | `CORE_config()`: defaults von allen Modulen einsammeln → `Config->load_defaults()` → `Config->load_file('config.json')`. Free-Port-Logik: wenn api.port=0 → Port finden → ConfigFile->save() → restart. Entfernt direkte `POPFile::Config->instance()->load($cfg)`. |

### Phase 3 — Module Base

| #     | Datei               | Änderung                                                                                                                  |
| ----- | ------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **6** | `POPFile/Module.pm` | `defaults()`-Methode (leer, Subklassen überschreiben). `module_config`/`global_config`/`config` (legacy warns) entfernen. |

### Phase 4 — Module (jedes bekommt %DEFAULTS + Role::Config read-only)

| #      | Datei                             |
| ------ | --------------------------------- |
| **7**  | `POPFile/API.pm`                  |
| **8**  | `Classifier/Bayes.pm`             |
| **9**  | `Classifier/WordMangle.pm`        |
| **10** | `Services/IMAP.pm`                |
| **11** | `Services/IMAP/Client.pm`         |
| **12** | `POPFile/Logger.pm`               |
| **13** | `POPFile/Activity.pm`             |
| **14** | `POPFile/History.pm`              |
| **15** | `Proxy/Proxy.pm` + POP3/SMTP/NNTP |

### Phase 5 — API Controller

| #      | Datei                              | Änderung                                                                                                                                                                                     |
| ------ | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **16** | `POPFile/API/Controller/Config.pm` | Nutzt `ConfigFile` direkt für write. Liest JSON, merged Änderungen, speichert atomar. Kein `configuration()->save_configuration()` mehr. `get_config()` liest direkt aus `Config` singleton. |
| **17** | `POPFile/API/Controller/IMAP.pm`   | Nutzt `ConfigFile` direkt für writes. Entfernt `POPFile::Config->instance()->load()` mid-flight.                                                                                             |

### Phase 6 — Cleanup

| #      | Datei                      | Änderung                                                                                                                                                                                                  |
| ------ | -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **18** | `POPFile/Configuration.pm` | Reduzieren auf: PID-Management, Pfad-Auflösung (`get_user_path`, `get_root_path`), Encryption-Helper. Parameter-Storage, `load_configuration`, `save_configuration`, `parameter`, `config_hash` entfernt. |
| **19** | `POPFile/ConfigFile.pm`    | Finaler Check.                                                                                                                                                                                            |

### Phase 7 — Tests
