import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class for setting up mock channels and utilities for testing
class TestHelpers {
  /// Sets up mock method channels for testing the epub viewer plugin
  static void setupMockChannels() {
    TestDefaultBinaryMessengerBinding.ensureInitialized();
    
    // Mock the main epub viewer channel
    _setupEpubViewerChannel();
    
    // Mock event channels
    _setupEventChannels();
    
    // Mock asset loading
    _setupAssetChannel();
  }

  /// Cleans up all mock channels
  static void cleanupMockChannels() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('vocsy_epub_viewer'), null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(const EventChannel('page'), null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(const EventChannel('highlights'), null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  }

  /// Sets up a mock method channel handler that tracks method calls
  static List<MethodCall> setupMethodCallTracking() {
    final methodCalls = <MethodCall>[];
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('vocsy_epub_viewer'), 
        (MethodCall methodCall) async {
      methodCalls.add(methodCall);
      return _handleMockMethodCall(methodCall);
    });
    
    return methodCalls;
  }

  /// Creates mock asset data for testing
  static void setupMockAsset(String assetPath, List<int> data) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      return ByteData.view(Uint8List.fromList(data).buffer);
    });
  }

  /// Sets up mock failure scenarios for testing error handling
  static void setupMockFailures({
    bool setConfigFails = false,
    bool openFails = false,
    bool openAssetFails = false,
    bool setChannelFails = false,
    bool closeFails = false,
  }) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('vocsy_epub_viewer'), 
        (MethodCall methodCall) async {
      
      final shouldFail = switch (methodCall.method) {
        'setConfig' => setConfigFails,
        'open' => openFails,
        'openAsset' => openAssetFails,
        'setChannel' => setChannelFails,
        'close' => closeFails,
        _ => false,
      };

      if (shouldFail) {
        throw PlatformException(
          code: 'TEST_ERROR',
          message: 'Test error for ${methodCall.method}',
        );
      }

      return _handleMockMethodCall(methodCall);
    });
  }

  static void _setupEpubViewerChannel() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('vocsy_epub_viewer'), 
        (MethodCall methodCall) async {
      return _handleMockMethodCall(methodCall);
    });
  }

  static void _setupEventChannels() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(const EventChannel('page'), MockStreamHandler());
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(const EventChannel('highlights'), MockStreamHandler());
  }

  static void _setupAssetChannel() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      // Return minimal mock asset data
      return ByteData.view(Uint8List.fromList([1, 2, 3, 4, 5]).buffer);
    });
  }

  static dynamic _handleMockMethodCall(MethodCall methodCall) {
    switch (methodCall.method) {
      case 'setConfig':
      case 'open':
      case 'openAsset':
      case 'setChannel':
      case 'close':
        return null; // Success
      default:
        throw PlatformException(
          code: 'UNIMPLEMENTED',
          message: 'Method ${methodCall.method} not implemented in mock',
        );
    }
  }
}

/// Mock stream handler for event channels
class MockStreamHandler implements StreamHandler {
  @override
  StreamSubscription<dynamic>? onListen(arguments, StreamController<dynamic> controller) {
    // Return a mock subscription that doesn't emit events
    return Stream<dynamic>.empty().listen(null);
  }

  @override
  StreamSubscription<dynamic>? onCancel(arguments) {
    return null;
  }
}

/// Test data factory for creating test objects
class TestDataFactory {
  /// Creates a sample EpubLocator for testing
  static Map<String, dynamic> createSampleEpubLocatorJson() {
    return {
      'bookId': 'test-book-123',
      'href': '/OEBPS/chapter01.xhtml',
      'created': 1609459200000, // Jan 1, 2021
      'locations': {
        'cfi': 'epubcfi(/0!/4/4[chapter01]/2/2/6)'
      }
    };
  }

  /// Creates a sample Locations object for testing
  static Map<String, dynamic> createSampleLocationsJson() {
    return {
      'cfi': 'epubcfi(/0!/4/4[test_chapter]/2/2/1:0)'
    };
  }

  /// Creates various test color values
  static List<int> getTestColorValues() {
    return [
      0xFF2196F3, // Colors.blue
      0xFFF44336, // Colors.red
      0xFF4CAF50, // Colors.green
      0xFFFFFFFF, // Colors.white
      0xFF000000, // Colors.black
      0xFF9C27B0, // Colors.purple
      0xFFFF9800, // Colors.orange
    ];
  }

  /// Creates test asset paths
  static List<String> getTestAssetPaths() {
    return [
      'assets/book1.epub',
      'assets/sample/book2.epub',
      'assets/library/classic-novel.epub',
      'assets/technical/manual.epub',
    ];
  }

  /// Creates invalid asset paths for negative testing
  static List<String> getInvalidAssetPaths() {
    return [
      'assets/book.pdf',
      'assets/document.docx',
      'assets/image.jpg',
      'invalid.epub',
      '',
    ];
  }
}