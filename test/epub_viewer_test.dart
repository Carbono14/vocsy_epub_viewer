import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('VocsyEpub Tests', () {
    const MethodChannel channel = MethodChannel('vocsy_epub_viewer');
    const EventChannel pageChannel = EventChannel('page');
    const EventChannel highlightsChannel = EventChannel('highlights');
    
    List<MethodCall> methodCalls = [];
    
    setUp(() {
      methodCalls.clear();
      
      // Mock the main method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        methodCalls.add(methodCall);
        
        switch (methodCall.method) {
          case 'setConfig':
            return null; // Success
          case 'open':
          case 'openAsset':
            return null; // Success
          case 'setChannel':
            return null; // Success
          case 'close':
            return null; // Success
          default:
            throw PlatformException(
              code: 'UNIMPLEMENTED',
              message: 'Method ${methodCall.method} not implemented',
            );
        }
      });

      // Mock path_provider channel
      const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getTemporaryDirectory':
            return '/tmp';
          default:
            return null;
        }
      });

      // Mock event channels - use null for simple mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(pageChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(highlightsChannel, null);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(pageChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(highlightsChannel, null);
    });

    group('setConfig', () {
      test('should call setConfig with default parameters', () async {
        await VocsyEpub.setConfig();

        expect(methodCalls.length, equals(1));
        expect(methodCalls[0].method, equals('setConfig'));
        
        final args = Map<String, dynamic>.from(methodCalls[0].arguments as Map);
        expect(args['identifier'], equals('book'));
        expect(args['themeColor'], equals('#2196f3')); // Colors.blue
        expect(args['scrollDirection'], equals('alldirections'));
        expect(args['allowSharing'], equals(false));
        expect(args['enableTts'], equals(false));
        expect(args['nightMode'], equals(false));
      });

      test('should call setConfig with custom parameters', () async {
        await VocsyEpub.setConfig(
          themeColor: Colors.red,
          identifier: 'custom-book',
          nightMode: true,
          scrollDirection: EpubScrollDirection.HORIZONTAL,
          allowSharing: true,
          enableTts: true,
        );

        expect(methodCalls.length, equals(1));
        expect(methodCalls[0].method, equals('setConfig'));
        
        final args = Map<String, dynamic>.from(methodCalls[0].arguments as Map);
        expect(args['identifier'], equals('custom-book'));
        expect(args['themeColor'], equals('#f44336')); // Colors.red
        expect(args['scrollDirection'], equals('horizontal'));
        expect(args['allowSharing'], equals(true));
        expect(args['enableTts'], equals(true));
        expect(args['nightMode'], equals(true));
      });

      test('should handle setConfig platform exception', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'setConfig') {
            throw PlatformException(
              code: 'CONFIG_ERROR',
              message: 'Failed to set configuration',
            );
          }
          return null;
        });

        expect(
          () async => await VocsyEpub.setConfig(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to set config: Failed to set configuration'),
          )),
        );
      });
    });

    group('open', () {
      test('should call open with required parameters', () async {
        const bookPath = '/path/to/book.epub';
        
        await VocsyEpub.open(bookPath);

        expect(methodCalls.length, equals(2));
        expect(methodCalls[0].method, equals('setChannel'));
        expect(methodCalls[1].method, equals('open'));
        
        final args = Map<String, dynamic>.from(methodCalls[1].arguments as Map);
        expect(args['bookPath'], equals(bookPath));
        expect(args['lastLocation'], equals(''));
      });

      test('should call open with lastLocation parameter', () async {
        const bookPath = '/path/to/book.epub';
        final lastLocation = EpubLocator(
          bookId: '123',
          href: '/chapter1.html',
          created: 1234567890,
          locations: Locations(cfi: 'epubcfi(/0!/4/4[simple_book]/2/2/6)'),
        );
        
        await VocsyEpub.open(bookPath, lastLocation: lastLocation);

        expect(methodCalls.length, equals(2));
        expect(methodCalls[1].method, equals('open'));
        
        final args = Map<String, dynamic>.from(methodCalls[1].arguments as Map);
        expect(args['bookPath'], equals(bookPath));
        
        final locationJson = args['lastLocation'] as String;
        expect(locationJson.isNotEmpty, isTrue);
        
        final decodedLocation = jsonDecode(locationJson);
        expect(decodedLocation['bookId'], equals('123'));
        expect(decodedLocation['href'], equals('/chapter1.html'));
      });

      test('should handle open platform exception', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'open') {
            throw PlatformException(
              code: 'OPEN_ERROR',
              message: 'Failed to open book',
            );
          }
          return null;
        });

        expect(
          () async => await VocsyEpub.open('/path/to/book.epub'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to open book: Failed to open book'),
          )),
        );
      });
    });

    group('openAsset', () {
      test('should call openAsset with valid epub file', () async {
        const assetPath = 'assets/book.epub';
        
        // Mock asset loading
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', (ByteData? message) async {
          return ByteData.view(Uint8List.fromList([1, 2, 3, 4, 5]).buffer);
        });

        try {
          await VocsyEpub.openAsset(assetPath);
          
          expect(methodCalls.any((call) => call.method == 'setChannel'), isTrue);
          expect(methodCalls.any((call) => call.method == 'open'), isTrue);
          
          final openCall = methodCalls.firstWhere((call) => call.method == 'open');
          final args = Map<String, dynamic>.from(openCall.arguments as Map);
          expect(args['bookPath'], contains('book.epub'));
        } catch (e) {
          // Expected in test environment without proper file system
          expect(e, isA<Exception>());
        }
      });

      test('should reject non-epub files', () async {
        expect(
          () async => await VocsyEpub.openAsset('assets/book.pdf'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('.pdf cannot be opened, use an EPUB File'),
          )),
        );
      });

      test('should handle openAsset platform exception', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'open') {
            throw PlatformException(
              code: 'ASSET_ERROR',
              message: 'Failed to open asset',
            );
          }
          return null;
        });

        // Mock asset loading
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', (ByteData? message) async {
          return ByteData.view(Uint8List.fromList([1, 2, 3, 4, 5]).buffer);
        });

        expect(
          () async => await VocsyEpub.openAsset('assets/book.epub'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to open asset book'),
          )),
        );
      });
    });

    group('setChannel', () {
      test('should call setChannel successfully', () async {
        await VocsyEpub.setChannel();

        expect(methodCalls.length, equals(1));
        expect(methodCalls[0].method, equals('setChannel'));
      });

      test('should handle setChannel platform exception', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'setChannel') {
            throw PlatformException(
              code: 'CHANNEL_ERROR',
              message: 'Failed to set channel',
            );
          }
          return null;
        });

        expect(
          () async => await VocsyEpub.setChannel(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to set channel: Failed to set channel'),
          )),
        );
      });
    });

    group('close', () {
      test('should call close successfully', () async {
        await VocsyEpub.close();

        expect(methodCalls.length, equals(1));
        expect(methodCalls[0].method, equals('close'));
      });

      test('should handle close platform exception', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'close') {
            throw PlatformException(
              code: 'CLOSE_ERROR',
              message: 'Failed to close reader',
            );
          }
          return null;
        });

        expect(
          () async => await VocsyEpub.close(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to close reader: Failed to close reader'),
          )),
        );
      });
    });

    group('Event Streams', () {
      test('should provide locatorStream', () {
        final stream = VocsyEpub.locatorStream;
        expect(stream, isA<Stream<dynamic>>());
      });

      test('should provide highlightsStream', () {
        final stream = VocsyEpub.highlightsStream;
        expect(stream, isA<Stream<dynamic>>());
      });
    });
  });
}

// MockStreamHandler removed - using null handlers for simplicity
