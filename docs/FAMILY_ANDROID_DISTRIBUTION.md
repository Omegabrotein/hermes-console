# Android Family Distribution

Family members get Hermes Console by **installing the APK from a GitHub release** — not from the Google Play Store. You build it, send the link, they tap Install. Updates do the same: you build a new APK, send the new link, it slides over the old install.

## Why this way (and not Play)

You chose side-load over Play Console. The reasons: no $25 fee, no Play Store review, no Google account needed on the family device, no Play Console rules to follow. The trade-off: each new version is one extra tap to install on the family device. The CI takes care of building the APK; you take care of the link.

## What "in-place update" means here

When a family member installs the first APK, Android stamps two things on it:

- **Package name**: `dev.xpetalab.hermesconsole` (set in `AndroidManifest.xml`, same across all our `full` builds)
- **Signing key**: the Flutter debug key, baked into the CI image. Same key on every CI run, so the second APK has the same key as the first.

When they install the second APK, Android checks those two things. They match, so the install is treated as an update, not a new app. The user's data (Hermes server URLs, voice settings, language, last chat) is preserved.

We also turned on Android's **auto-backup** in the manifest:

- `android:allowBackup="true"` in `AndroidManifest.xml`
- Backup include rules in `res/xml/backup_rules.xml` and `res/xml/data_extraction_rules.xml`

These add an extra safety net: if a family member ever does a full uninstall+reinstall, the app's data restores from the device's Google backup on next install.

## What you do for each release

1. Push to `ios-port` (or run the workflow from the GitHub Actions page).
2. CI produces a 100–110 MB arm64 APK and uploads it as an artifact.
3. You create a GitHub release and drop the APK in.

## How to share with family

Pick the channel that works for your family. The most common:

- **Telegram / iMessage / WhatsApp** — send the GitHub release link. Family member opens in their phone's browser, taps the APK, taps Install. (Some browsers, including Brave, sometimes stall on the final rename. If that happens: long-press the link → "Download with another browser" → Chrome.)
- **Email** — same as above.
- **USB transfer** — copy the APK to a flash drive, plug into the family Android, tap to install. Easiest for parents who don't want to mess with browsers.

After the first install, the icon shows up on the home screen and works offline. Server settings get re-downloaded from the Hermes servers over Tailscale, so each family device needs to be on the same Tailscale network as the home servers.

## When things go wrong

| Symptom | Fix |
|---|---|
| "App not installed" or "conflicts with the older version" | Family member has an older version installed under a different signing key. Send them a one-time instruction: uninstall the old Hermes Console, install the new APK, re-add their Hermes server. After that, updates will work forever because every future build uses the same debug key. |
| "For your security your phone isn't allowed to install unknown apps" | Family member needs to allow installs from their browser in **Settings → Apps → [their browser] → Install unknown apps**. This is a one-time toggle per browser. |
| Browser stalls on the final step of the download (101/101 MB but no "Open" button) | Switch to a different browser (Chrome usually finishes cleanly). Or copy the APK from a Telegram-attached file using the Files app. |
| "Parse error — there was a problem parsing the package" | The APK is corrupt or the browser didn't finish the rename. Re-download, or use a different browser. |
