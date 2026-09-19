import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:EthioFarm/core/l10n/app_localizations.dart';
import 'package:EthioFarm/features/weather/models/weather_forecast_model.dart';
import 'package:EthioFarm/features/weather/widgets/rainfall_chart.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 300,
          child: child,
        ),
      ),
    );
  }

  group('RainfallChart widget tests', () {
    testWidgets('renders empty state when forecast is null', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const RainfallChart(forecast: null)));
      await tester.pumpAndSettle();

      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('renders volumetric bars and 7-day total metric', (tester) async {
      const mockForecast = WeatherForecastModel(
        source: 'Open-Meteo',
        latitude: 9.03,
        longitude: 38.74,
        generatedAt: '2026-09-14T00:00:00Z',
        daily: DailyWeatherModel(
          time: [
            '2026-09-14',
            '2026-09-15',
            '2026-09-16',
            '2026-09-17',
            '2026-09-18',
            '2026-09-19',
            '2026-09-20',
          ],
          temperatureMax: [22, 23, 21, 20, 22, 24, 23],
          temperatureMin: [12, 13, 11, 10, 11, 12, 13],
          precipitationSum: [4.5, 0.0, 12.0, 2.0, 0.0, 8.5, 1.0],
          relativeHumidity: [70, 65, 80, 75, 60, 85, 70],
          windspeedMax: [10, 12, 15, 8, 9, 14, 11],
          precipitationProbabilityMax: [60.0, 10.0, 90.0, 40.0, 15.0, 85.0, 35.0],
        ),
      );

      await tester.pumpWidget(buildTestableWidget(const RainfallChart(forecast: mockForecast)));
      await tester.pumpAndSettle();

      // Total rain = 4.5 + 0.0 + 12.0 + 2.0 + 0.0 + 8.5 + 1.0 = 28.0 mm
      expect(find.text('7-Day Total: 28.0 mm'), findsOneWidget);
      // Rainy days with val >= 1.0: 4.5, 12.0, 2.0, 8.5, 1.0 = 5 days
      expect(find.text('5 rainy days expected'), findsOneWidget);

      // Verify today label is displayed
      expect(find.text('Today'), findsOneWidget);

      // Verify tooltips and semantics exist
      expect(find.byType(Tooltip), findsNWidgets(7));
      expect(find.byType(Semantics), findsWidgets);
    });
  });
}
