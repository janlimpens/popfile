# POPFile Changelog

## main (unreleased) — post-v1.1.3 rewrite

This branch represents a substantial modernisation of POPFile beyond the last
released version (v1.1.3, 2012).

### Architecture

- Replaced the legacy fork-per-request HTTP UI with an in-process
  [Mojolicious](https://mojolicious.org) HTTP server running on `Mojo::IOLoop`.
- Replaced all Perl-templated HTML pages with a Svelte 5 single-page
  application served from `public/`.
- REST API exposed under `/api/v1/*`; backend and frontend are fully decoupled.
- Switched from ad-hoc `print` logging to `Log::Any` with a custom adapter
  (`POPFile::Log::Adapter`) that supports file output, stdout, ring buffer, and
  level filtering — all live-reconfigurable from the UI.
- Adopted `Object::Pad` class syntax and `use feature 'signatures'` throughout.
- Dependency management moved to Carton (`cpanfile` + `local/`).
- CI via GitHub Actions.

### Classification

- `Classifier::Bayes` now computes a **per-bucket** `not_likely` floor
  (previously global), eliminating classification bias when one bucket
  dominates the corpus.
- `Classifier::WordMangle` filters noise tokens before they reach the corpus:
  - HTML/CSS pseudo-tokens that carry embedded values
    (`html:css*`, `html:comment`, `html:fontcolor*`, `html:backcolor*`,
    `html:fontsize*`, `html:imgwidth*`, `html:imgheight*`).
  - Zero-width character entity artifacts (`zwnj`, `zwj`).
  - Random opaque strings detected via impossible consonant bigrams
    (`jk` anywhere; `hg`, `bk`, `dk` at word start) — tracks tracking IDs
    and hashed CSS class names out of the corpus.
- Database indices added for `matrix(bucketid)`, `history(userid, committed)`,
  `history(bucketid)`, `history(hash)`, `history(inserted)`,
  `magnets(bucketid)`.

### IMAP

- New `Services::IMAP` module: recurring poll timer, per-folder UID tracking,
  automatic classification and folder moves, reclassification detection by
  observing message moves into mapped output folders.
- UID-next state persisted in `imap_folder_state` table; override bug that
  caused repeated reclassification of old messages fixed.
- Message-ID-backed direct moves for reclassification from the web UI.
- Training triggers via filesystem flag files (`popfile.train*`).

### Web UI

- History view: pagination with configurable page size (persisted to config and
  `sessionStorage`), search, bucket filter, bulk reclassify.
- Corpus / Word view: sortable columns, per-bucket word inspector, stopword
  management, word move and delete.
- Settings page exposes all runtime configuration including logging options.
- IMAP configuration page: watched folders, bucket-folder mappings, live folder
  discovery, connection test.
- Self-hosted Material Symbols icons; no external font CDN dependency.

---

## v1.1.3 (2012)

Last release by the original POPFile Core Team. See `v1.1.3.change.txt` for
the original release notes.
