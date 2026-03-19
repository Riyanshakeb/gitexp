# AGENTS.md

## Cursor Cloud specific instructions

This repository contains a **Banner Calculator** Android application (`BannerCalculator/`) — a price calculator for printing/graphics businesses.

### Prerequisites (not in update script — install once)

- **Java 17+** (OpenJDK 21 available in the VM by default)
- **Android SDK**: Install to `$HOME/android-sdk` with `platforms;android-34` and `build-tools;34.0.0`. The update script does not install the SDK; set `ANDROID_HOME=$HOME/android-sdk` before building.

### Building the app

```bash
export ANDROID_HOME=$HOME/android-sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
cd BannerCalculator
./gradlew assembleDebug    # debug APK
./gradlew assembleRelease  # signed release APK (uses release-key.jks in project root)
./gradlew lint             # Android lint
```

### Project structure

- `BannerCalculator/` — Full Android project (Kotlin, Room DB, Material Design 3)
- Package: `com.azizgraphics.clcltr`
- 3 screens via bottom navigation: Calculate, History, Settings
- Fully offline, no internet required

### Gotchas

- The Gradle wrapper (`gradlew`) must have LF line endings. If it shows "cannot execute", run `sed -i 's/\r$//' gradlew`.
- The release keystore (`release-key.jks`) is in the `BannerCalculator/` root — do not commit to production repos; here it is for development/demo purposes only.
- No Android emulator is available in the Cloud Agent VM. APK verification is done via `aapt dump badging` and `apksigner verify`.
