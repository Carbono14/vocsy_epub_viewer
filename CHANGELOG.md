## [1.1.0] - 2025-08-13

### 🎉 Major Modernization Update

This release brings the plugin up to date with the latest Flutter, Android, and iOS versions.

### ✨ Added
- Support for Flutter 3.32+ and Dart 3.8+
- Proper error handling with try-catch blocks and detailed error messages
- `close()` method to properly dispose of the reader
- Better null safety implementation
- Improved type safety with proper return types

### 🔧 Changed
- **BREAKING**: Minimum Flutter version is now 3.32.0
- **BREAKING**: Minimum Dart version is now 3.6.0
- **BREAKING**: Android minSdk increased from 21 to 26
- **BREAKING**: iOS deployment target increased from 9.0 to 14.0
- Updated Android compileSdk to 35 (Android 15)
- Updated Android targetSdk to 35
- Updated to Gradle 8.10.2 and Android Gradle Plugin 8.7.3
- Updated to Kotlin 2.1.0 and Java 17 compatibility
- Updated dependencies to latest versions
- Improved plugin architecture with proper lifecycle management
- Enhanced method channel communication with better error handling
- Fixed deprecated UIApplication.shared.keyWindow usage on iOS
- Replaced deprecated jcenter with mavenCentral

### 🛠️ Technical Improvements
- Modern plugin registration using FlutterPlugin instead of deprecated PluginRegistry.Registrar
- Proper ActivityAware implementation for Android lifecycle management
- Better error handling across all platforms
- Improved Swift code with modern syntax and guard statements
- Enhanced null safety throughout the codebase
- Updated example app to demonstrate latest capabilities

### 📖 Documentation
- Updated README with new requirements and setup instructions
- Added comprehensive installation guide for Android and iOS
- Updated usage examples with proper error handling
- Created detailed migration plan documentation

### 🐛 Bug Fixes
- Fixed compilation issues with latest Flutter versions
- Resolved deprecated API warnings
- Fixed Android build configuration for modern Gradle versions
- Improved iOS compatibility with latest versions

### ⚠️ Migration Notes
If upgrading from 1.0.x:
1. Update your Flutter version to 3.32.0 or higher
2. Update iOS deployment target to 14.0 in your Podfile
3. Update Android minSdk to 26 in your build.gradle
4. Ensure Java 17 compatibility in your Android project
5. Add proper error handling around VocsyEpub method calls

## [1.0.1] - Previous Release
* IOS ISSUE FIXED!!
* LATEST ANDROID VERSION SUPPORT!
* ANDROID 12 SUPPORTED !
* STABLE VERSION

## 1.0.0
* README UPDATE

## 0.0.8

* Bug Fixed for Locator in android

## 0.0.7

* Bug Fixed for Android

## 0.0.6

* IOS ISSUE FIXED!!
* LATEST IOS VERSION SUPPORT!
* ANDROID 12 SUPPORTED !

## 0.0.5

* Bug Fixed

## 0.0.4

* Bug Fixed

## 0.0.3

* Bug Fixed

## 0.0.2

* Bug Fixed

## 0.0.1

* initial release.
