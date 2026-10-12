# Android Family Distribution

This document explains how family members get the **Hermes Console** app on their Android phones, and how updates slide over the existing install without losing user data.

## TL;DR (what each person does)

| Who | Does what |
|---|---|
| **You (publisher)** | Pay $25 once on the Google account that will own Hermes Console. Create the app card. Add the family Gmail list. Hand the service account JSON and upload keystore to GitHub. |
| **Each family member** | Opens the opt-in link once on their Android phone. Taps Install. Gets updates automatically. |
| **The GitHub CI** | Builds the play AAB on every push to `ios-port`, signs it with your upload keystore, uploads to Internal testing. |

## What the family sees

- A normal Play Store listing titled **"Hermes Console (Internal)"** — only visible to the email addresses on the internal tester list.
- An "Update available" notification. Tapping it slides the new AAB over the existing install. **No data loss**, because the
  `android:allowBackup="true"` flag plus `data_extraction_rules.xml` include the SharedPreferences, databases and files used by the app.

## What you set up once

1. **Pay the developer fee** at <https://play.google.com/console> on the publishing Google account (the one in `ANDROID_PLAY_SERVICE_ACCOUNT_JSON`'s parent). Skip if already paid.
2. **Create the app** in Play Console:
   - Default language: English. App name: `Hermes Console`. Free. App type: App.
   - On **Releases → Testing → Internal testing**, create a track named `family` and add up to 100 testers (use Gmail addresses).
3. **Service account JSON** (the robot login that GitHub uses to publish):
   - Play Console → **Settings → API access** → **Create service account** → follow the link to Google Cloud Console.
   - Grant that service account the **Release manager** role on the Hermes Console app.
   - Download the JSON. Its full contents become the `ANDROID_PLAY_SERVICE_ACCOUNT_JSON` GitHub secret. One-time copy only — never check it in.
4. **Upload keystore** (the file that signs the AABs):
   - Your existing app upload keystore. The same one used for any other Flutter Android app you've published under any package id. A keystore can sign multiple apps.
   - As plaintext, add `ANDROID_KEY_PROPERTIES` to GitHub secrets. Four lines:
     ```
     storeFile=upload.keystore
     storePassword=…
     keyAlias=…
     keyPassword=…
     ```
   - As base64, add `ANDROID_UPLOAD_KEYSTORE_BASE64`. Get it with `base64 -w0 path/to/upload.keystore` (Git Bash on Windows) or `base64 < path/to/upload.keystore | tr -d '\n'` (macOS).

## CI behavior with secrets present

| Secrets | Behavior |
|---|---|
| key properties + keystore only | Builds signed AAB and stops at the artifact. No Play upload. |
| key properties + keystore + service account JSON | Builds signed AAB and uploads as **completed** to the chosen track (default: `internal`). Still must be manually promoted from internal → production in Play Console. |
| none | Builds unsigned AAB and stops. |

## Promoting a build

Even with full secrets, Play will refuse to auto-promote from internal → production. Promote by hand in Play Console: **Releases → Internal testing** → select the build → **Promote release** → pick the next track.
