# Fork reconciliation preservation accounting

Upstream pin: 83883b8339e8a0a895d2c1515518805ab257446d (v1.3.1).
Fork delta: content-equivalent v1.3.0 base 7c51c99 to 7b121b4.
91/91 paths accounted for; all 42 ios files byte-identical.

Policy divergence (pre-existing fork, not a merge fix): retain Android
allowBackup=true with backup_rules and data_extraction_rules so server settings
survive updates/reinstalls. Upstream H7 excludes everything. The adapted S1 test
asserts encrypted-capability-gated cloud backup and journal/shm exclusions in both
cloud and device-transfer sections; the manifest and rules are not changed.
This increases backed-up user-data exposure relative to upstream; encrypted
secure-storage key portability and real-device restore remain unverified.

Vietnamese restart warning is preserved verbatim, but is stale: it still says
brief interruption of active sessions rather than running turns/this chat/resend.
setRestartGatewayBody exists in app_vi.arb, so it is NOT an untranslated-key
English fallback and is not added to untranslated_vi.json. The test checks the
actual catalog text explicitly; translation parity is not semantic parity.

| Path | Status | Reason |
| --- | --- | --- |
| .github/workflows/android-full.yml | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| .github/workflows/android-qa.yml | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| .github/workflows/ios.yml | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| .gitignore | PORTED-WITH-CHANGES | Preserves fork ignores and excludes isolated proof worktrees, Kotlin cache and reconciliation logs. |
| android/app/build.gradle.kts | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| android/app/src/main/AndroidManifest.xml | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| android/app/src/main/res/xml/backup_rules.xml | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| android/app/src/main/res/xml/data_extraction_rules.xml | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| docs/FAMILY_ANDROID_DISTRIBUTION.md | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/.gitignore | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/ExportOptions.plist | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Flutter/AppFrameworkInfo.plist | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Flutter/Debug.xcconfig | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Flutter/Release.xcconfig | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Podfile | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner.xcodeproj/project.pbxproj | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner.xcworkspace/contents.xcworkspacedata | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/AppDelegate.swift | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Base.lproj/LaunchScreen.storyboard | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Base.lproj/Main.storyboard | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Info.plist | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/Runner-Bridging-Header.h | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/Runner/SceneDelegate.swift | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| ios/RunnerTests/RunnerTests.swift | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| lib/core/bots/ui/roster/roster_rows.dart | CONFLICT-RESOLVED | Registry-backed Strings replaces es/en branching; vi inherits English relative-time copy. |
| lib/core/screens/admin_integrations_copy.dart | CONFLICT-RESOLVED | Retains upstream Strings facade; missing Vietnamese i18n131 messages inherit English. |
| lib/core/screens/chat_screen.dart | CONFLICT-RESOLVED | Keeps upstream restored-turn i18n131 copy with English fallback for vi. |
| lib/core/screens/mission_bot_routine_sheet.dart | CONFLICT-RESOLVED | Keeps upstream fromStrings factory and all language catalogs; context-free vi resolves English. |
| lib/core/screens/mission_bot_task_sheet.dart | CONFLICT-RESOLVED | Keeps upstream Strings copy rather than binary locale branching; vi gaps inherit English. |
| lib/core/screens/mission_control_copy.dart | CONFLICT-RESOLVED | Retains upstream localized facade; English template implements the fork non-Spanish fallback. |
| lib/core/screens/mission_control_screen.dart | CONFLICT-RESOLVED | Retains upstream room-copy localization with English fallback for vi. |
| lib/core/screens/onboarding/onboarding_scanner.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| lib/core/screens/voice_settings_screen.dart | PORTED-WITH-CHANGES | Clean three-way application retains fork delta alongside upstream changes. |
| lib/core/services/android_launch_action_inbox.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| lib/core/services/notifications/notification_presentation.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| lib/core/services/notifications/notification_service.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| lib/core/services/notifications/voice_notification_controller.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| lib/core/services/platform/app_settings.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| lib/core/services/voice/conversation/full_duplex_barge_in_monitor.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| lib/core/services/voice/conversation/local_voice_conversation_controller.dart | CONFLICT-RESOLVED | Keeps 60ms feed cadence and iOS 150ms tail guard; vi messages use English registry record. |
| lib/core/services/voice/speech_renderer.dart | CONFLICT-RESOLVED | Keeps upstream multi-language grammar; vi registry explicitly uses English speech normalization. |
| lib/core/services/voice/stt_engine.dart | CONFLICT-RESOLVED | Preserves fork 800ms endpoint; registry now supplies vi_VN, vi-VN, vi locales. |
| lib/core/services/voice/tts_engine.dart | CONFLICT-RESOLVED | Preserves 80-character first synthesis block; registry supplies vi-VN TTS and fallback. |
| lib/core/services/voice/tts_model_manager.dart | CONFLICT-RESOLVED | Combines upstream model catalog with fork VAIS1000 asset, size and SHA-256 unchanged. |
| lib/core/services/voice/voice_lang.dart | CONFLICT-RESOLVED | Upstream region-normalizing resolver uses shared registry, extended with vi instead of restoring obsolete inline set. |
| lib/core/services/voice/voice_service.dart | PORTED-WITH-CHANGES | Clean three-way application retains fork delta alongside upstream changes. |
| lib/core/services/voice/voice_settings.dart | CONFLICT-RESOLVED | Retains upstream registry defaults; vi record supplies VAIS1000 and af_heart with Kokoro fallback comment. |
| lib/core/widgets/server_voice_control_surface.dart | PORTED-WITH-CHANGES | Clean three-way application retains fork delta alongside upstream changes. |
| lib/l10n/app_en.arb | PORTED-WITH-CHANGES | Retains fork keys; English template now carries original Spanish placeholder types and restored chaUploadTitle. |
| lib/l10n/app_es.arb | PORTED-WITH-CHANGES | Retains fork keys and upstream translations; restores chaUploadTitle without removing Vietnamese equivalent. |
| lib/l10n/app_vi.arb | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| lib/main.dart | CONFLICT-RESOLVED | Retains all upstream locale choices and resolver; adds Tiếng Việt as the tenth locale. |
| test/ios_native_parity_test.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| test/l10n_vi_parity_test.dart | PORTED-WITH-CHANGES | Checks exact untranslated manifest, existing-message placeholder parity, and no extra keys. |
| test/notification_presentation_call_test.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| test/notification_presentation_parity_test.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| test/notification_presentation_service_test.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| test/onboarding_scanner_settings_feedback_test.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| test/server_voice_control_surface_test.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| test/voice/conversation/full_duplex_barge_in_monitor_test.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| test/voice/neural_tts_prewarm_test.dart | PRESERVED-AS-IS | Byte-identical to fork 7b121b4. |
| test/voice_lang_test.dart | PORTED-WITH-CHANGES | Keeps fork vi cases; locale-set assertion reads new shared registry. |
| test/voice_settings_fields_test.dart | PORTED-WITH-CHANGES | Clean three-way application retains fork delta alongside upstream changes. |
| test/voice_test.dart | CONFLICT-RESOLVED | Retains both upstream Portuguese and fork Vietnamese defaults/STT/TTS cases plus 800ms regression. |
