import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum DisasterMapLayer {
  allHazards,
  seismology,
  soilDegradation,
  landslides,
  drought,
  floods,
  volcanoes,
  farmPlots,
}

enum BaseMapType {
  voyager,
  topographic,
  osm,
  dark,
}

class WoredaSpatialProfile {
  final String id;
  final String woredaName;
  final String region;
  final String aez;
  final int elevation;
  final LatLng centroid;
  final List<LatLng> polygon;
  final double compositeRisk; // 0.0 to 1.0
  final String riskLevel; // LOW, MODERATE, HIGH, CRITICAL
  final double pgaG; // Peak ground acceleration
  final double soilLossTonsPerHa; // RUSLE annual soil loss
  final double slopePercent; // DEM slope
  final double spi3; // Drought SPI-3 index
  final double riverDischargeM3s; // GloFAS flow
  final double nearestVolcanoDistKm;
  final String nearestVolcanoName;
  final String amharicAdvisory;
  final String oromoAdvisory;

  const WoredaSpatialProfile({
    required this.id,
    required this.woredaName,
    required this.region,
    required this.aez,
    required this.elevation,
    required this.centroid,
    required this.polygon,
    required this.compositeRisk,
    required this.riskLevel,
    required this.pgaG,
    required this.soilLossTonsPerHa,
    required this.slopePercent,
    required this.spi3,
    required this.riverDischargeM3s,
    required this.nearestVolcanoDistKm,
    required this.nearestVolcanoName,
    required this.amharicAdvisory,
    required this.oromoAdvisory,
  });
}

class RegionCameraPreset {
  final String name;
  final LatLng center;
  final double zoom;
  const RegionCameraPreset(this.name, this.center, this.zoom);
}

class FaultLineProfile {
  final String name;
  final String description;
  final List<LatLng> points;
  final Color color;

  const FaultLineProfile({
    required this.name,
    required this.description,
    required this.points,
    required this.color,
  });
}

class VolcanoProfile {
  final String name;
  final String region;
  final LatLng location;
  final String type;
  final String alertLevel;
  final double hazardRadiusKm;

  const VolcanoProfile({
    required this.name,
    required this.region,
    required this.location,
    required this.type,
    required this.alertLevel,
    required this.hazardRadiusKm,
  });
}

class RiverCorridorProfile {
  final String name;
  final List<LatLng> path;
  final double currentFlowM3s;
  final double floodThresholdM3s;

  const RiverCorridorProfile({
    required this.name,
    required this.path,
    required this.currentFlowM3s,
    required this.floodThresholdM3s,
  });
}
