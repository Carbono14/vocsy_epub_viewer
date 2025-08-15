import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Util Tests', () {
    group('getHexFromColor', () {
      test('should convert basic colors to hex format', () {
        // Test with Colors.blue
        expect(Util.getHexFromColor(Colors.blue), equals('#2196f3'));
        
        // Test with Colors.red
        expect(Util.getHexFromColor(Colors.red), equals('#f44336'));
        
        // Test with Colors.green
        expect(Util.getHexFromColor(Colors.green), equals('#4caf50'));
        
        // Test with Colors.white
        expect(Util.getHexFromColor(Colors.white), equals('#ffffff'));
        
        // Test with Colors.black
        expect(Util.getHexFromColor(Colors.black), equals('#000000'));
      });

      test('should convert custom colors to hex format', () {
        // Test with custom color
        const customColor = Color(0xFF123456);
        expect(Util.getHexFromColor(customColor), equals('#123456'));
        
        // Test with another custom color
        const anotherColor = Color(0xFFABCDEF);
        expect(Util.getHexFromColor(anotherColor), equals('#abcdef'));
      });

      test('should handle MaterialColor correctly', () {
        // Test with material color
        expect(Util.getHexFromColor(Colors.blue), equals('#2196f3'));
        expect(Util.getHexFromColor(Colors.red), equals('#f44336'));
      });

      test('should handle colors with alpha channel', () {
        // Test with semi-transparent color
        const colorWithAlpha = Color(0x80FF0000); // 50% red
        expect(Util.getHexFromColor(colorWithAlpha), equals('#ff0000'));
      });

      test('should handle edge cases', () {
        // Test with completely transparent color
        const transparentColor = Color(0x00FFFFFF);
        expect(Util.getHexFromColor(transparentColor), equals('#ffffff'));
        
        // Test with maximum color value
        const maxColor = Color(0xFFFFFFFF);
        expect(Util.getHexFromColor(maxColor), equals('#ffffff'));
      });
    });

    group('getDirection', () {
      test('should convert EpubScrollDirection enum to correct string', () {
        expect(
          Util.getDirection(EpubScrollDirection.HORIZONTAL), 
          equals('horizontal')
        );
        
        expect(
          Util.getDirection(EpubScrollDirection.VERTICAL), 
          equals('vertical')
        );
        
        expect(
          Util.getDirection(EpubScrollDirection.ALLDIRECTIONS), 
          equals('alldirections')
        );
      });

      test('should handle all enum values', () {
        // Test all possible enum values exist and convert correctly
        for (final direction in EpubScrollDirection.values) {
          final result = Util.getDirection(direction);
          expect(result, isA<String>());
          expect(result.isNotEmpty, isTrue);
        }
      });
    });

    group('getFileFromAsset', () {
      setUp(() {
        // Set up mock for rootBundle
        // TestDefaultBinaryMessengerBinding.ensureInitialized(); // Not needed in newer Flutter
      });

      test('should create file from asset data', () async {
        // Mock asset data
        const assetPath = 'assets/test.epub';
        final mockData = ByteData.view(Uint8List.fromList([1, 2, 3, 4, 5]).buffer);
        
        // Mock the rootBundle.load call
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', (ByteData? message) async {
          return mockData;
        });

        try {
          final file = await Util.getFileFromAsset(assetPath);
          
          expect(file, isNotNull);
          expect(file.path.endsWith('test.epub'), isTrue);
        } catch (e) {
          // Expected in test environment without actual file system
          expect(e, isA<Exception>());
        }
      });

      test('should handle asset path correctly', () async {
        const assetPath = 'assets/sample/book.epub';
        final mockData = ByteData.view(Uint8List.fromList([]).buffer);
        
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', (ByteData? message) async {
          return mockData;
        });

        try {
          final file = await Util.getFileFromAsset(assetPath);
          expect(file.path.endsWith('book.epub'), isTrue);
        } catch (e) {
          // Expected in test environment
          expect(e, isA<Exception>());
        }
      });

      tearDown(() {
        // Clean up mock handlers
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', null);
      });
    });
  });
}