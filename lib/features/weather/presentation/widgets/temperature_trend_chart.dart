import 'package:flutter/material.dart';
import '../../../../core/models/weather_model.dart';

class TemperatureTrendChart extends StatelessWidget {
  final WeatherForecastModel? forecast;

  const TemperatureTrendChart({
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
        final maxTemp = daily.temperatureMax[index];
        final minTemp = daily.temperatureMin[index];

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
              const Icon(Icons.thermostat, color: Colors.orange, size: 20),
              const SizedBox(height: 8),
              Text(
                '${maxTemp.toStringAsFixed(0)}°',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                '${minTemp.toStringAsFixed(0)}°',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}
