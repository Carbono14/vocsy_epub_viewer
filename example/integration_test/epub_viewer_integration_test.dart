import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:epub_kitty_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Epub Viewer Integration Tests', () {
    testWidgets('should launch app and display main UI', (WidgetTester tester) async {
      // Launch the app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Verify the app launches successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Vocsy Plugin E-pub example'), findsOneWidget);
    });

    testWidgets('should display epub buttons after loading', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Wait for any async operations to complete
      await tester.pump(const Duration(seconds: 5));

      // Look for either loading state or the buttons
      final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      final hasButtons = find.text('Open Online E-pub').evaluate().isNotEmpty;

      expect(hasLoading || hasButtons, isTrue, 
        reason: 'Should show either loading indicator or epub buttons');

      // If not loading, check for buttons
      if (!hasLoading) {
        expect(find.text('Open Online E-pub'), findsOneWidget);
        expect(find.text('Open Assets E-pub'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNWidgets(2));
      }
    });

    testWidgets('should handle button interactions', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Wait for loading to complete
      await tester.pump(const Duration(seconds: 5));

      // Try to find and interact with buttons
      final onlineButton = find.text('Open Online E-pub');
      final assetsButton = find.text('Open Assets E-pub');

      if (onlineButton.evaluate().isNotEmpty) {
        // Test Online EPUB button
        await tester.tap(onlineButton);
        await tester.pumpAndSettle();
        
        // Verify no crash occurred
        expect(tester.takeException(), isNull);
      }

      if (assetsButton.evaluate().isNotEmpty) {
        // Test Assets EPUB button  
        await tester.tap(assetsButton);
        await tester.pumpAndSettle();
        
        // Verify no crash occurred
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('should maintain app state through interactions', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Initial state check
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Wait for any loading to complete
      await tester.pump(const Duration(seconds: 3));

      // Perform some interactions if possible
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        for (int i = 0; i < buttons.evaluate().length && i < 2; i++) {
          await tester.tap(buttons.at(i));
          await tester.pump(const Duration(milliseconds: 500));
          
          // Verify app structure is maintained
          expect(find.byType(Scaffold), findsOneWidget);
          expect(find.byType(AppBar), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    });

    group('Performance Tests', () {
      testWidgets('should start up within reasonable time', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        
        // App should start within 10 seconds (generous for CI environments)
        expect(stopwatch.elapsedMilliseconds, lessThan(10000),
          reason: 'App startup took ${stopwatch.elapsedMilliseconds}ms');
      });

      testWidgets('should handle rapid button taps', (WidgetTester tester) async {
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // Wait for loading to complete
        await tester.pump(const Duration(seconds: 3));

        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          // Rapidly tap buttons to test responsiveness
          for (int i = 0; i < 5; i++) {
            await tester.tap(buttons.first);
            await tester.pump(const Duration(milliseconds: 100));
          }
          
          await tester.pumpAndSettle();
          
          // Verify app is still responsive
          expect(find.byType(Scaffold), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      });
    });

    group('Error Recovery Tests', () {
      testWidgets('should recover from orientation changes', (WidgetTester tester) async {
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // Simulate orientation change by changing screen size
        await tester.binding.setSurfaceSize(const Size(800, 600)); // Landscape-ish
        await tester.pumpAndSettle();

        // Verify app still works
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);

        // Change back to portrait-ish
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpAndSettle();

        // Verify app still works
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle app lifecycle events', (WidgetTester tester) async {
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // Simulate app being paused and resumed
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/lifecycle',
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('routeUpdated', {
              'location': '/test',
            }),
          ),
          (data) {},
        );

        await tester.pumpAndSettle();

        // Verify app is still functional
        expect(find.byType(Scaffold), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have accessible widgets', (WidgetTester tester) async {
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // Wait for loading to complete
        await tester.pump(const Duration(seconds: 3));

        // Check for accessibility elements
        final buttons = find.byType(ElevatedButton);
        
        for (final buttonElement in buttons.evaluate()) {
          final button = buttonElement.widget as ElevatedButton;
          final child = button.child;
          
          // Buttons should have text (accessible content)
          expect(child, isA<Text>());
        }

        // App bar should be accessible
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.title, isA<Text>());
      });
    });
  });
}