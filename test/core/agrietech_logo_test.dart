import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/core/widgets/agrietech_logo.dart';

void main() {
  group('AgriEtechLogo Widget Tests', () {
    testWidgets('renders stacked hero logo variant with 3-segment wordmark and tagline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgriEtechLogo.stacked(
              size: 80,
              showTagline: true,
            ),
          ),
        ),
      );

      expect(find.byType(AgriEtechLogo), findsOneWidget);
      expect(find.byType(RichText), findsWidgets);
      expect(find.text('SMART FARMING & EARLY WARNING'), findsOneWidget);
    });

    testWidgets('renders horizontal variant for app bar with 3-segment wordmark', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgriEtechLogo.horizontal(
              size: 32,
              showTagline: false,
            ),
          ),
        ),
      );

      expect(find.byType(AgriEtechLogo), findsOneWidget);
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('renders pure 3-segment wordmark variant without icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgriEtechLogo.wordmark(
              size: 36,
            ),
          ),
        ),
      );

      expect(find.byType(AgriEtechLogo), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);
      expect(find.byIcon(Icons.eco), findsNothing);
    });

    testWidgets('renders iconOnly variant with custom vector Ethiopian emblem', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgriEtechLogo.iconOnly(
              size: 48,
            ),
          ),
        ),
      );

      expect(find.byType(AgriEtechLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byIcon(Icons.eco), findsNothing);
    });
  });
}
