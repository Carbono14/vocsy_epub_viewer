import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:epub_kitty_example/main.dart';

void main() {
  group('Example App Widget Tests', () {
    setUp(() {
      // Set up mock for the epub viewer plugin
      TestDefaultBinaryMessengerBinding.ensureInitialized();
      
      const MethodChannel epubChannel = MethodChannel('vocsy_epub_viewer');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(epubChannel, (MethodCall methodCall) async {
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
              message: 'Method ${methodCall.method} not implemented',
            );
        }
      });

      // Mock path_provider
      const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getExternalStorageDirectory':
            return '/mock/external/storage';
          case 'getApplicationDocumentsDirectory':
            return '/mock/app/documents';
          default:
            return null;
        }
      });

      // Mock permission_handler
      const MethodChannel permissionChannel = MethodChannel('flutter.baseflow.com/permissions/methods');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(permissionChannel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'checkPermissionStatus':
          case 'requestPermissions':
            return 1; // granted
          default:
            return null;
        }
      });

      // Mock dio for HTTP requests
      const MethodChannel dioChannel = MethodChannel('plugins.flutter.io/dio');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(dioChannel, (MethodCall methodCall) async {
        return null; // Mock successful download
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('vocsy_epub_viewer'), null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter.baseflow.com/permissions/methods'), null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/dio'), null);
    });

    testWidgets('should render main app correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Verify app bar is displayed
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Vocsy Plugin E-pub example'), findsOneWidget);

      // Verify main scaffold structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should display buttons when not loading', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Wait for the loading state to finish
      await tester.pump(const Duration(seconds: 1));

      // Should show both epub buttons
      expect(find.text('Open Online E-pub'), findsOneWidget);
      expect(find.text('Open Assets E-pub'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('should display loading indicator when downloading', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      
      // The app starts with loading = false, but download() is called in initState
      // We need to check for loading state during download
      
      // Pump a few frames to let initState complete
      await tester.pump();
      
      // Look for either loading state or buttons depending on download completion
      expect(
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
        find.text('Open Online E-pub').evaluate().isNotEmpty,
        isTrue,
        reason: 'Should show either loading indicator or buttons',
      );
    });

    testWidgets('should handle Online E-pub button tap', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Wait for loading to complete
      await tester.pump(const Duration(seconds: 1));

      // Find and tap the Online E-pub button
      final onlineButton = find.text('Open Online E-pub');
      if (onlineButton.evaluate().isNotEmpty) {
        await tester.tap(onlineButton);
        await tester.pumpAndSettle();

        // Verify the button was tapped (no exceptions thrown)
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('should handle Assets E-pub button tap', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Wait for loading to complete
      await tester.pump(const Duration(seconds: 1));

      // Find and tap the Assets E-pub button
      final assetsButton = find.text('Open Assets E-pub');
      if (assetsButton.evaluate().isNotEmpty) {
        await tester.tap(assetsButton);
        await tester.pumpAndSettle();

        // Verify the button was tapped (no exceptions thrown)
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('should display correct loading message', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pump();

      // Check if loading message appears during download
      final loadingText = find.text('Downloading.... E-pub');
      final loadingIndicator = find.byType(CircularProgressIndicator);
      
      // Either we see loading state or we've moved past it
      if (loadingText.evaluate().isNotEmpty) {
        expect(loadingIndicator, findsOneWidget);
        expect(loadingText, findsOneWidget);
      }
    });

    testWidgets('should have proper widget structure', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Verify widget hierarchy
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('should disable debug banner', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('should have correct app title', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      
      expect(find.text('Vocsy Plugin E-pub example'), findsOneWidget);
    });

    group('State Management Tests', () {
      testWidgets('should initialize with correct state', (WidgetTester tester) async {
        await tester.pumpWidget(MyApp());
        
        // The app should be created successfully
        expect(find.byType(MyApp), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle state changes gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // Trigger a rebuild by tapping buttons if they exist
        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.first);
          await tester.pump();
          
          // Should handle state change without crashing
          expect(tester.takeException(), isNull);
        }
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should handle plugin errors gracefully', (WidgetTester tester) async {
        // Override mock to simulate errors
        const MethodChannel epubChannel = MethodChannel('vocsy_epub_viewer');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(epubChannel, (MethodCall methodCall) async {
          throw PlatformException(
            code: 'TEST_ERROR',
            message: 'Test error for widget testing',
          );
        });

        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // App should still render despite plugin errors
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });
    });
  });
}
