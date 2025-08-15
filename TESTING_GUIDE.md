# 🧪 Testing Guide for Vocsy Epub Viewer

This guide provides comprehensive instructions for testing the modernized plugin.

## ✅ Prerequisites Verified

- ✅ Flutter 3.32.8+ installed
- ✅ Dart 3.8.1+ installed
- ✅ Plugin analysis passes with no issues
- ✅ Dependencies resolved successfully

## 🔧 **1. Basic Build Tests**

### Plugin Analysis
```bash
cd vocsy_epub_viewer
flutter analyze
# Should show: "No issues found!"
```

### Dependency Resolution
```bash
flutter pub get
# Should complete without errors
```

### Example App Setup
```bash
cd example
flutter pub get
flutter analyze
# Should complete successfully
```

## 📱 **2. Platform-Specific Testing**

### **Android Testing**

#### Requirements Check:
- ✅ Android SDK 34+ (API Level 34+)
- ✅ Java 17 installed
- ✅ Gradle 8.10.2+

#### Build Test:
```bash
cd example
flutter build apk --debug
```

#### Run on Device/Emulator:
```bash
flutter run -d <android-device-id>
```

#### Key Test Points:
- [ ] App builds without Gradle errors
- [ ] App launches successfully
- [ ] Epub files can be opened from assets
- [ ] Epub files can be opened from file system
- [ ] Page navigation works
- [ ] Highlights feature works
- [ ] Configuration settings apply correctly
- [ ] Error handling displays proper messages

### **iOS Testing**

#### Requirements Check:
- ✅ Xcode 15+ installed
- ✅ iOS 14.0+ deployment target
- ✅ CocoaPods updated

#### Build Test:
```bash
cd example/ios
pod install
cd ..
flutter build ios --debug --no-codesign
```

#### Run on Simulator/Device:
```bash
flutter run -d <ios-device-id>
```

#### Key Test Points:
- [ ] Pod installation completes successfully
- [ ] App builds without Swift compilation errors
- [ ] App launches on iOS simulator/device
- [ ] Epub files can be opened
- [ ] FolioReader integration works correctly
- [ ] Page navigation functions properly
- [ ] Configuration options work as expected

## 🧪 **3. Functional Testing**

### **Basic Plugin API Tests**

Create a test app to verify all plugin methods:

```dart
// Test 1: Configuration
try {
  await VocsyEpub.setConfig(
    themeColor: Colors.blue,
    identifier: "test-book",
    scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
    allowSharing: true,
    enableTts: true,
    nightMode: false,
  );
  print("✅ setConfig succeeded");
} catch (e) {
  print("❌ setConfig failed: $e");
}

// Test 2: Open from assets
try {
  await VocsyEpub.openAsset('assets/test.epub');
  print("✅ openAsset succeeded");
} catch (e) {
  print("❌ openAsset failed: $e");
}

// Test 3: Stream listeners
VocsyEpub.locatorStream.listen((locator) {
  print("📍 Page location: $locator");
});

VocsyEpub.highlightsStream.listen((highlight) {
  print("🖍️ Highlight: $highlight");
});

// Test 4: Close reader
try {
  await VocsyEpub.close();
  print("✅ close succeeded");
} catch (e) {
  print("❌ close failed: $e");
}
```

### **Error Handling Tests**

```dart
// Test invalid file
try {
  await VocsyEpub.openAsset('invalid.pdf');
} catch (e) {
  print("✅ Correctly caught error: $e");
}

// Test opening without config
try {
  await VocsyEpub.open('test.epub');
} catch (e) {
  print("✅ Correctly caught config error: $e");
}
```

## 🏗️ **4. Build System Testing**

### **Gradle Configuration Test**
```bash
cd example/android
./gradlew assembleDebug
# Should build successfully with Gradle 8.10.2
```

### **iOS Build Test**
```bash
cd example
flutter build ios --debug --no-codesign
# Should build successfully with iOS 14.0+ target
```

## 📊 **5. Performance Testing**

### **Memory Usage**
- Monitor memory usage while opening large epub files
- Check for memory leaks when opening/closing multiple books
- Verify proper cleanup when calling `close()`

### **Build Times**
- Measure Flutter build times with new dependencies
- Compare Android build times with Gradle 8.10.2
- Monitor iOS build times with updated deployment target

## 🔍 **6. Compatibility Testing**

### **Flutter Versions**
Test with different Flutter versions:
- ✅ Flutter 3.32.8 (verified working)
- [ ] Flutter 3.30.x
- [ ] Flutter 3.29.x

### **Platform Versions**
- **Android**: Test on API 26, 30, 34, 35
- **iOS**: Test on iOS 14.0, 15.0, 16.0, 17.0+

### **Device Testing**
- [ ] Physical Android devices
- [ ] Android emulators
- [ ] iOS simulators  
- [ ] Physical iOS devices

## 🐛 **7. Issue Tracking**

### **Common Issues to Watch For:**
1. **Gradle build failures** - Check Java 17 compatibility
2. **iOS compilation errors** - Verify Xcode version and deployment target
3. **Plugin registration failures** - Test method channel communication
4. **Dependency conflicts** - Monitor for version incompatibilities
5. **Platform-specific crashes** - Test on actual devices

### **Reporting Issues**
When filing issues, include:
- Flutter version (`flutter --version`)
- Platform and OS version
- Device type (physical/emulator/simulator)
- Full error logs
- Minimal reproduction code

## ✅ **8. Automated Testing**

### **Unit Tests**
```bash
cd vocsy_epub_viewer
flutter test
```

### **Integration Tests**
```bash
cd example
flutter test integration_test/
```

### **CI/CD Pipeline**
Consider setting up automated testing for:
- Multiple Flutter versions
- Multiple platform versions  
- Build verification
- Basic functionality tests

## 📝 **Testing Checklist**

Before releasing:
- [ ] All analysis issues resolved
- [ ] Builds successfully on Android and iOS
- [ ] Core functionality tested on real devices
- [ ] Error handling working correctly
- [ ] Documentation updated
- [ ] Example app demonstrates all features
- [ ] Performance acceptable on target devices
- [ ] No memory leaks detected
- [ ] Backwards compatibility verified (where applicable)

## 🎯 **Next Steps**

1. Run through this testing guide systematically
2. Document any issues found
3. Test the example app thoroughly on real devices
4. Consider publishing to pub.dev for community testing
5. Gather feedback from early adopters

---

**Happy Testing! 🎉**

If you encounter any issues during testing, refer to the troubleshooting section in the README or file an issue on GitHub.