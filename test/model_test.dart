import 'package:flutter_test/flutter_test.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

void main() {
  group('Model Tests', () {
    group('Locations', () {
      test('should create Locations from valid JSON', () {
        final json = {
          'cfi': 'epubcfi(/0!/4/4[simple_book]/2/2/6)'
        };

        final locations = Locations.fromJson(json);

        expect(locations.cfi, equals('epubcfi(/0!/4/4[simple_book]/2/2/6)'));
      });

      test('should create Locations with null cfi from empty JSON', () {
        final json = <String, dynamic>{};

        final locations = Locations.fromJson(json);

        expect(locations.cfi, isNull);
      });

      test('should convert Locations to JSON correctly', () {
        final locations = Locations(cfi: 'epubcfi(/0!/4/4[simple_book]/2/2/6)');

        final json = locations.toJson();

        expect(json, equals({
          'cfi': 'epubcfi(/0!/4/4[simple_book]/2/2/6)'
        }));
      });

      test('should convert Locations with null cfi to JSON correctly', () {
        final locations = Locations();

        final json = locations.toJson();

        expect(json, equals({
          'cfi': null
        }));
      });

      test('should create Locations with constructor parameters', () {
        final locations = Locations(cfi: 'test-cfi-string');

        expect(locations.cfi, equals('test-cfi-string'));
      });

      test('should handle different cfi formats', () {
        final testCases = [
          'epubcfi(/6/4!/4/2/2/6)',
          'epubcfi(/0!/4/4[chapter1]/2/2/1:0)',
          '',
          'simple-location',
        ];

        for (final cfi in testCases) {
          final locations = Locations(cfi: cfi);
          final json = locations.toJson();
          final fromJson = Locations.fromJson(json);

          expect(fromJson.cfi, equals(cfi));
        }
      });
    });

    group('EpubLocator', () {
      test('should create EpubLocator from valid JSON with all fields', () {
        final json = {
          'bookId': '12345',
          'href': '/OEBPS/ch01.xhtml',
          'created': 1539934158390,
          'locations': {
            'cfi': 'epubcfi(/0!/4/4[simple_book]/2/2/6)'
          }
        };

        final locator = EpubLocator.fromJson(json);

        expect(locator.bookId, equals('12345'));
        expect(locator.href, equals('/OEBPS/ch01.xhtml'));
        expect(locator.created, equals(1539934158390));
        expect(locator.locations, isNotNull);
        expect(locator.locations!.cfi, equals('epubcfi(/0!/4/4[simple_book]/2/2/6)'));
      });

      test('should create EpubLocator from JSON with missing optional fields', () {
        final json = {
          'bookId': 'test-book'
        };

        final locator = EpubLocator.fromJson(json);

        expect(locator.bookId, equals('test-book'));
        expect(locator.href, isNull);
        expect(locator.created, isNull);
        expect(locator.locations, isNull);
      });

      test('should create EpubLocator from JSON with null locations', () {
        final json = {
          'bookId': 'test-book',
          'href': '/chapter1.html',
          'created': 1234567890,
          'locations': null
        };

        final locator = EpubLocator.fromJson(json);

        expect(locator.bookId, equals('test-book'));
        expect(locator.href, equals('/chapter1.html'));
        expect(locator.created, equals(1234567890));
        expect(locator.locations, isNull);
      });

      test('should convert EpubLocator to JSON correctly with all fields', () {
        final locations = Locations(cfi: 'epubcfi(/0!/4/4[simple_book]/2/2/6)');
        final locator = EpubLocator(
          bookId: '12345',
          href: '/OEBPS/ch01.xhtml',
          created: 1539934158390,
          locations: locations,
        );

        final json = locator.toJson();

        expect(json, equals({
          'bookId': '12345',
          'href': '/OEBPS/ch01.xhtml',
          'created': 1539934158390,
          'locations': {
            'cfi': 'epubcfi(/0!/4/4[simple_book]/2/2/6)'
          }
        }));
      });

      test('should convert EpubLocator to JSON correctly with null fields', () {
        final locator = EpubLocator();

        final json = locator.toJson();

        expect(json, equals({
          'bookId': null,
          'href': null,
          'created': null,
        }));
      });

      test('should create EpubLocator with constructor parameters', () {
        final locations = Locations(cfi: 'test-cfi');
        final locator = EpubLocator(
          bookId: 'book-123',
          href: '/chapter2.html',
          created: 9876543210,
          locations: locations,
        );

        expect(locator.bookId, equals('book-123'));
        expect(locator.href, equals('/chapter2.html'));
        expect(locator.created, equals(9876543210));
        expect(locator.locations, equals(locations));
        expect(locator.locations!.cfi, equals('test-cfi'));
      });

      test('should handle JSON serialization round trip', () {
        final originalLocator = EpubLocator(
          bookId: 'test-book-id',
          href: '/OEBPS/chapter-03.xhtml',
          created: 1609459200000, // Jan 1, 2021
          locations: Locations(cfi: 'epubcfi(/0!/4/4[chapter3]/2/2/1:0)'),
        );

        // Convert to JSON and back
        final json = originalLocator.toJson();
        final restoredLocator = EpubLocator.fromJson(json);

        expect(restoredLocator.bookId, equals(originalLocator.bookId));
        expect(restoredLocator.href, equals(originalLocator.href));
        expect(restoredLocator.created, equals(originalLocator.created));
        expect(restoredLocator.locations!.cfi, equals(originalLocator.locations!.cfi));
      });

      test('should handle edge cases in data', () {
        final testCases = [
          {
            'description': 'empty strings',
            'data': {
              'bookId': '',
              'href': '',
              'created': 0,
              'locations': {'cfi': ''}
            }
          },
          {
            'description': 'very long strings',
            'data': {
              'bookId': 'a' * 1000,
              'href': '/very/long/path/' + 'segment/' * 100 + 'file.html',
              'created': 9223372036854775807, // max int64
              'locations': {'cfi': 'epubcfi(' + 'x' * 500 + ')'}
            }
          },
          {
            'description': 'special characters',
            'data': {
              'bookId': 'book-with-special-chars-!@#\$%^&*()',
              'href': '/OEBPS/chapter with spaces & symbols.xhtml',
              'created': -1234567890, // negative timestamp
              'locations': {'cfi': 'epubcfi(/0!/4/4[special-chars-@#\$]/2/2/6)'}
            }
          }
        ];

        for (final testCase in testCases) {
          final locator = EpubLocator.fromJson(testCase['data'] as Map<String, dynamic>);
          final json = locator.toJson();
          final restoredLocator = EpubLocator.fromJson(json);

          expect(restoredLocator.bookId, equals(locator.bookId),
              reason: 'Failed for ${testCase['description']} - bookId');
          expect(restoredLocator.href, equals(locator.href),
              reason: 'Failed for ${testCase['description']} - href');
          expect(restoredLocator.created, equals(locator.created),
              reason: 'Failed for ${testCase['description']} - created');
          expect(restoredLocator.locations?.cfi, equals(locator.locations?.cfi),
              reason: 'Failed for ${testCase['description']} - locations.cfi');
        }
      });
    });

    group('EpubScrollDirection enum', () {
      test('should have all expected values', () {
        expect(EpubScrollDirection.values.length, equals(3));
        expect(EpubScrollDirection.values, contains(EpubScrollDirection.HORIZONTAL));
        expect(EpubScrollDirection.values, contains(EpubScrollDirection.VERTICAL));
        expect(EpubScrollDirection.values, contains(EpubScrollDirection.ALLDIRECTIONS));
      });

      test('should convert enum to correct string via Util.getDirection', () {
        expect(Util.getDirection(EpubScrollDirection.HORIZONTAL), equals('horizontal'));
        expect(Util.getDirection(EpubScrollDirection.VERTICAL), equals('vertical'));
        expect(Util.getDirection(EpubScrollDirection.ALLDIRECTIONS), equals('alldirections'));
      });
    });
  });
}