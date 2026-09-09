import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:EthioFarm/features/analytics/widgets/ethiopia_gis_map_widget.dart';

void main() {
  group('EthiopiaGisMapWidget Standardization & Place/Hazard Filtering Tests', () {
    Widget createWidgetUnderTest({DisasterMapLayer initialLayer = DisasterMapLayer.allHazards}) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: 800,
                child: EthiopiaGisMapWidget(
                  height: 700,
                  initialLayer: initialLayer,
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Renders GIS Map with Place Filter and Hazard Switcher Ribbons', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify Header & HUD elements
      expect(find.text('Ethiopia Spatial GIS Command'), findsOneWidget);
      expect(find.text('Jurisdiction:'), findsOneWidget);
      expect(find.text('🇪🇹 National'), findsOneWidget);
      expect(find.text('Oromia (ኦሮሚያ)'), findsOneWidget);
      expect(find.text('Amhara (አማራ)'), findsOneWidget);
      expect(find.text('Tigray (ትግራይ)'), findsOneWidget);

      // Verify Hazard Chips
      expect(find.text('🚨 All Hazards'), findsOneWidget);
      expect(find.text('☀️ Drought (SPI-3)'), findsOneWidget);
      expect(find.text('🌊 Floods (GloFAS)'), findsOneWidget);

      // Verify Floating HUD Pill
      expect(find.text('All Ethiopia'), findsWidgets);

      // Verify Legend Pill
      expect(find.text('Critical'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
      expect(find.text('Safe'), findsOneWidget);
    });

    testWidgets('Tapping Region chip updates active jurisdiction in HUD pill', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and tap Oromia region chip
      final oromiaChip = find.text('Oromia (ኦሮሚያ)');
      expect(oromiaChip, findsOneWidget);
      await tester.tap(oromiaChip);
      await tester.pumpAndSettle();

      // Verify HUD shows Oromia
      expect(find.text('Oromia'), findsWidgets);
    });

    testWidgets('Tapping scientific legend expands metric threshold details', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Initially collapsed: metric threshold text is not displayed
      expect(find.text('Scientific Metric Thresholds:'), findsNothing);

      // Tap legend to expand
      final legendTapTarget = find.byKey(const Key('scientific_legend_toggle'));
      expect(legendTapTarget, findsOneWidget);
      await tester.tap(legendTapTarget);
      await tester.pumpAndSettle();

      // Verify expanded scientific thresholds are displayed
      expect(find.text('Scientific Metric Thresholds:'), findsOneWidget);
      expect(find.text('• Drought: SPI-3 < -1.2 (Severe Deficit)'), findsOneWidget);
      expect(find.text('• Flood: River Discharge > 250 m³/s'), findsOneWidget);
    });

    testWidgets('Tapping Search Woreda icon opens search modal dialog', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find search icon button
      final searchButton = find.byTooltip('Search Woreda');
      expect(searchButton, findsOneWidget);
      await tester.tap(searchButton);
      await tester.pumpAndSettle();

      // Verify search modal appears
      expect(find.text('Fly to Woreda on Map'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Fly to Woreda on Map'), findsNothing);
    });

    testWidgets('Switching hazard layer chip updates active layer state', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap Drought hazard layer
      final droughtChip = find.text('☀️ Drought (SPI-3)');
      expect(droughtChip, findsOneWidget);
      await tester.tap(droughtChip);
      await tester.pumpAndSettle();

      // Verify ChoiceChip is selected
      final choiceChipWidget = tester.widget<ChoiceChip>(find.ancestor(
        of: droughtChip,
        matching: find.byType(ChoiceChip),
      ));
      expect(choiceChipWidget.selected, true);
    });
  });
}
