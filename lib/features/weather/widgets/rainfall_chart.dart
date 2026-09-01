import 'package:flutter/material.dart';
import '../models/weather_forecast_model.dart';

class RainfallChart extends StatelessWidget {
  final WeatherForecastModel? forecast;

  const RainfallChart({
    super.key,
    this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    if (forecast == null) {
      return const Center(child: Text('No data'));
    }

    final daily = forecast!.daily;
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: daily.time.length,
      itemBuilder: (context, index) {
        final date = daily.time[index];
        final precip = daily.precipitationSum[index];

        return Container(
          width: 70,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date.length >= 10 ? date.substring(5) : date,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Icon(Icons.water_drop, color: Colors.blue, size: 20),
              const SizedBox(height: 8),
              Text(
                '${precip.toStringAsFixed(1)} mm',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
