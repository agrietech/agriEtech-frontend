import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:EthioFarm/core/widgets/agrietech_logo.dart';

void main() {
  group('EthioFarmLogo Widget Tests', () {
    testWidgets('renders stacked hero logo variant with 3-segment wordmark and tagline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EthioFarmLogo.stacked(
              size: 80,
              showTagline: true,
            ),
          ),
        ),
      );

      expect(find.byType(EthioFarmLogo), findsOneWidget);
      expect(find.byType(RichText), findsWidgets);
      expect(find.text('SMART FARMING SYSTEM'), findsOneWidget);
    });

    testWidgets('renders horizontal variant for app bar with 3-segment wordmark', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EthioFarmLogo.horizontal(
              size: 32,
              showTagline: false,
            ),
          ),
        ),
      );

      expect(find.byType(EthioFarmLogo), findsOneWidget);
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('renders pure 3-segment wordmark variant without icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EthioFarmLogo.wordmark(
              size: 36,
            ),
          ),
        ),
      );

      expect(find.byType(EthioFarmLogo), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);
      expect(find.byIcon(Icons.eco), findsNothing);
    });

    testWidgets('renders iconOnly variant with custom vector Ethiopian emblem', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EthioFarmLogo.iconOnly(
              size: 48,
            ),
          ),
        ),
      );

      expect(find.byType(EthioFarmLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byIcon(Icons.eco), findsNothing);
    });
  });
}
