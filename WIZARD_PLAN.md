# Setup Wizard — Plan

Linear wizard on first launch (no `popfile.cfg` or no mailbox configured).
Re-triggerable from Settings. Uses existing i18n keys wherever possible.

## Screens

### 1. Welcome → Email address
- One sentence what POPFile does (`Imap_Description`)
- **Email address** field (the only thing the user MUST type)
- "Find settings" button
- Skip link → empty settings

### 2. Auto-detect (runs after email entered)
Tries to discover the right server, port, and encryption from the email domain:

1. Check **known provider list** (Gmail, Outlook, Yahoo, iCloud, GMX, Web.de, Zoho,
   Fastmail, Proton, etc.) — if found, use known-good settings immediately
2. Try common **hostname patterns**: `imap.<domain>`, `mail.<domain>`, `<domain>`
3. Try **ports in order**: 993 (SSL), 143 (STARTTLS), 143 (plain)
4. First successful IMAP connection wins
5. If IMAP fails entirely, repeat with POP3 (ports 995, 110)
6. If nothing works → fall through to manual entry

If auto-detect succeeds: form is pre-filled, user just confirms.
If it fails: form is empty, user fills manually, provider-specific hints shown if known.

### 3. Confirm / Correct server settings
- Pre-filled from auto-detect, or empty for manual entry
- **Server** (`Imap_Server`)
- **Port** (`Imap_Port`)
- **Encryption**: SSL/TLS | STARTTLS | None (radio, `Wizard_Encryption*` keys)
- **Login** (`Imap_Login`, pre-filled from email address)
- **Password** (`Imap_Password`)
- **Test Connection** button
- Provider hint (only shown if manual + known provider):
  *"For Gmail you need an app password. See https://..."*
- Next enabled when test passes

### 4. Folder Mapping
- Server folders as checklist (reuse Wizard UI, `Imap_Wizard*` keys)
- Spam/Junk pre-mapped to "Spam" bucket
- Default folders (INBOX, Sent, Trash, Drafts) filtered out
- User checks desired folders
- Next → creates buckets & mappings

### 5. Training (optional)
- `Imap_TrainingHint`
- Train now / Skip (`Imap_WizardTrain` / `Imap_WizardClose`)

### 6. Done
- Summary: protocol, X folders watched, Y buckets created
- [x] Enable service (`Settings_EnableService`)
- Button: Go to Dashboard (`Wizard_GoToDashboard`)

## Known provider database (embedded, small)

```
gmail.com        imap.gmail.com        993  SSL     (app password required)
outlook.com      outlook.office365.com 993  SSL
hotmail.com      outlook.office365.com 993  SSL
yahoo.com        imap.mail.yahoo.com   993  SSL     (app password required)
icloud.com       imap.mail.me.com      993  SSL     (app-specific password)
gmx.net          imap.gmx.net          993  SSL
gmx.de          imap.gmx.net          993  SSL
web.de          imap.web.de           993  SSL
zoho.com        imap.zoho.com         993  SSL
fastmail.com     imap.fastmail.com     993  SSL
proton.me       127.0.0.1            1143  none    (requires Proton Bridge)
mailbox.org      imap.mailbox.org      993  SSL
posteo.de        imap.posteo.de        993  SSL
```

If provider needs an app password, show a one-line hint with the provider's help URL.

## New keys needed (~20)
Wizard_Email, Wizard_FindSettings, Wizard_AutoDetected, Wizard_Encryption,
Wizard_EncryptionSSL, Wizard_EncryptionSTARTTLS, Wizard_EncryptionNone,
Wizard_ManualEntry, Wizard_ProviderHint, Wizard_GoToDashboard,
ProviderHint_gmail, ProviderHint_yahoo, ProviderHint_icloud, ProviderHint_proton,
Wizard_Done
