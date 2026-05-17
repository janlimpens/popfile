# JSON Schema Config Validation

## Entscheidung

Config-Validierung via JSON Schema wird VORGEPLANT aber SPÄTER implementiert. Die aktuelle Rewrite-Phase (Schritte 1–19) bleibt davon unberührt.

## Ziel

`POPFile::Configuration` wird zum neuen Config-Singleton. Es validiert `config.json` beim Laden UND Schreiben gegen ein JSON Schema. Fehlermeldungen sind präzise, das Schema ist gleichzeitig Doku.

## Architektur (später)

```
config.schema.json  ──►  POPFile::Configuration (singleton)
                              │
                              ├── load()   → validiert + frozen store
                              ├── get(ns, key)
                              └── write(ns, key, value) → validiert + atomar
```

Ersetzt: `Config.pm` + `ConfigFile.pm`.

## Schema (Entwurf)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "version": { "const": 2 },
    "api": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "port": {
          "type": "integer",
          "minimum": 0,
          "maximum": 65535,
          "default": 0
        },
        "password": { "type": "string", "default": "" },
        "static_dir": { "type": "string", "default": "public" },
        "local": { "type": "boolean", "default": true },
        "page_size": { "type": "integer", "minimum": 1, "default": 25 },
        "word_page_size": { "type": "integer", "minimum": 1, "default": 50 },
        "session_dividers": { "type": "boolean", "default": true },
        "wordtable_format": { "type": "string", "default": "" },
        "locale": {
          "type": "string",
          "default": "",
          "enum": [
            "",
            "de",
            "en",
            "ja",
            "ko",
            "fr",
            "es",
            "nl",
            "it",
            "pt",
            "ru",
            "zh"
          ]
        },
        "open_browser": { "type": "boolean", "default": true }
      }
    },
    "bayes": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "database": { "type": "string", "default": "popfile.db" },
        "dbconnect": { "type": "string", "default": "" },
        "dbuser": { "type": "string", "default": "" },
        "dbauth": { "type": "string", "default": "" },
        "corpus": { "type": "string", "default": "corpus" },
        "sqlite_backup": { "type": "boolean", "default": false },
        "sqlite_fast_writes": { "type": "boolean", "default": false },
        "unclassified_weight": { "type": "integer", "default": 100 },
        "subject_mod_pos": { "type": "boolean", "default": false },
        "xpl_angle": { "type": "boolean", "default": false },
        "stopword_ratio": { "type": "integer", "default": 0 }
      }
    },
    "GLOBAL": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "timeout": { "type": "integer", "minimum": 1, "default": 60 },
        "msgdir": { "type": "string", "default": "messages/" },
        "message_cutoff": {
          "type": "integer",
          "minimum": 1,
          "default": 100000
        },
        "debug": { "type": "integer", "minimum": 0, "maximum": 3, "default": 0 }
      }
    },
    "config": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "piddir": { "type": "string", "default": "./" },
        "pidcheck_interval": { "type": "integer", "minimum": 0, "default": 5 }
      }
    },
    "history": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "history_days": { "type": "integer", "minimum": 0, "default": 30 },
        "archive": { "type": "boolean", "default": false },
        "archive_classes": { "type": "integer", "minimum": 0, "default": 0 },
        "archive_dir": { "type": "string", "default": "" }
      }
    },
    "imap": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "hostname": { "type": "string", "default": "" },
        "port": {
          "type": "integer",
          "minimum": 1,
          "maximum": 65535,
          "default": 143
        },
        "login": { "type": "string", "default": "" },
        "password": { "type": "string", "default": "" },
        "use_ssl": { "type": "boolean", "default": false },
        "enabled": { "type": "boolean", "default": false },
        "training_mode": { "type": "boolean", "default": false },
        "expunge": { "type": "boolean", "default": false },
        "update_interval": { "type": "integer", "minimum": 1, "default": 300 },
        "training_limit": { "type": "integer", "minimum": 0, "default": 0 }
      }
    },
    "logger": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "logdir": { "type": "string", "default": "" },
        "level": {
          "type": "integer",
          "minimum": 0,
          "maximum": 4,
          "default": 2
        },
        "log_to_stdout": { "type": "boolean", "default": false },
        "log_sql": { "type": "boolean", "default": false }
      }
    },
    "pop3": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "port": {
          "type": "integer",
          "minimum": 1,
          "maximum": 65535,
          "default": 1110
        },
        "secure_port": {
          "type": "integer",
          "minimum": 1,
          "maximum": 65535,
          "default": 995
        },
        "local": { "type": "boolean", "default": true },
        "secure_server": { "type": "string", "default": "" },
        "toptoo": { "type": "boolean", "default": false },
        "separator": { "type": "string", "default": ":" },
        "enabled": { "type": "boolean", "default": false }
      }
    },
    "smtp": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "port": {
          "type": "integer",
          "minimum": 1,
          "maximum": 65535,
          "default": 25
        },
        "chain_server": { "type": "string", "default": "" },
        "chain_port": {
          "type": "integer",
          "minimum": 1,
          "maximum": 65535,
          "default": 25
        },
        "local": { "type": "boolean", "default": true },
        "enabled": { "type": "boolean", "default": false }
      }
    },
    "nntp": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "port": {
          "type": "integer",
          "minimum": 1,
          "maximum": 65535,
          "default": 119
        },
        "local": { "type": "boolean", "default": true },
        "headtoo": { "type": "boolean", "default": false },
        "separator": { "type": "string", "default": ":" },
        "enabled": { "type": "boolean", "default": false }
      }
    },
    "wordmangle": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "stemming": { "type": "boolean", "default": false },
        "auto_detect_language": { "type": "boolean", "default": false }
      }
    }
  }
}
```

## Kompatibilität mit aktuellem Code

Der aktuelle `Config.pm`-Singleton muss NICHT geändert werden. Wenn wir später auf Schema-Validierung umstellen:

1. `_normalize` entfällt — Schema validiert Typen bereits
2. `get(ns, key)` bleibt identisch
3. `write(ns, key, val)` validiert gegen Schema vorm Schreiben
4. `ConfigFile` wird von `POPFile::Configuration` absorbiert

## Perl-Validator

Empfohlen: `JSON::Schema::Modern` (aktiv maintained, Draft 2020-12). Installation via Carton.
