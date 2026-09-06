import 'package:flutter/material.dart';

/// Standard WMO (World Meteorological Organization) Weather Condition Types
enum WeatherConditionType {
  sunny,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rainy,
  thunderstorm,
  frost,
  windy,
}

/// Rich condition metadata with imagery, atmospheric gradients, and multilingual names
class WeatherConditionData {
  final WeatherConditionType type;
  final String key;
  final String nameEn;
  final String nameAm;
  final String nameOm;
  final String imagePath;
  final String supabaseUrl;
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;
  final Color badgeColor;
  final Color shadowColor;

  const WeatherConditionData({
    required this.type,
    required this.key,
    required this.nameEn,
    required this.nameAm,
    required this.nameOm,
    required this.imagePath,
    required this.supabaseUrl,
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
    required this.badgeColor,
    required this.shadowColor,
  });

  String getLocalizedName(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'am':
        return nameAm;
      case 'om':
        return nameOm;
      default:
        return nameEn;
    }
  }
}

/// World Meteorological Organization & International Standard Weather Theme Engine
class WeatherTheme {
  static const String _basePath = 'assets/images/weather';
  static const String _supabaseBase =
      'https://uhktbbeqqdsfkooyrgmq.supabase.co/storage/v1/object/public/diagnose/weather';

  /// Sunny / Clear Sky
  static const WeatherConditionData sunny = WeatherConditionData(
    type: WeatherConditionType.sunny,
    key: 'sunny',
    nameEn: 'Sunny & Clear',
    nameAm: 'ፀሐያማ እና ጥርት ያለ',
    nameOm: 'Aduu fi Qulqulluu',
    imagePath: '$_basePath/weather_sunny.jpg',
    supabaseUrl: '$_supabaseBase/weather_sunny.jpg',
    icon: Icons.wb_sunny_rounded,
    gradientColors: [
      Color(0xFF0284C7), // Azure sky blue
      Color(0xFF0369A1), // Deep sky
      Color(0xFFD97706), // Solar amber
    ],
    accentColor: Color(0xFFF59E0B),
    badgeColor: Color(0x33F59E0B),
    shadowColor: Color(0x4DF59E0B),
  );

  /// Partly Cloudy / Scattered Clouds
  static const WeatherConditionData partlyCloudy = WeatherConditionData(
    type: WeatherConditionType.partlyCloudy,
    key: 'partly_cloudy',
    nameEn: 'Partly Cloudy',
    nameAm: 'ከፊል ደመናማ',
    nameOm: 'Duumessa Muraasa',
    imagePath: '$_basePath/weather_partly_cloudy.jpg',
    supabaseUrl: '$_supabaseBase/weather_partly_cloudy.jpg',
    icon: Icons.cloud_queue_rounded,
    gradientColors: [
      Color(0xFF0EA5E9),
      Color(0xFF0284C7),
      Color(0xFF475569),
    ],
    accentColor: Color(0xFF38BDF8),
    badgeColor: Color(0x3338BDF8),
    shadowColor: Color(0x330284C7),
  );

  /// Overcast / Heavy Cloud Cover
  static const WeatherConditionData cloudy = WeatherConditionData(
    type: WeatherConditionType.cloudy,
    key: 'cloudy',
    nameEn: 'Overcast & Cloudy',
    nameAm: 'ሙሉ በሙሉ ደመናማ',
    nameOm: 'Duumessa Guutuu',
    imagePath: '$_basePath/weather_cloudy.jpg',
    supabaseUrl: '$_supabaseBase/weather_cloudy.jpg',
    icon: Icons.cloud_rounded,
    gradientColors: [
      Color(0xFF334155),
      Color(0xFF475569),
      Color(0xFF1E293B),
    ],
    accentColor: Color(0xFF94A3B8),
    badgeColor: Color(0x3394A3B8),
    shadowColor: Color(0x4D0F172A),
  );

  /// Fog & Atmospheric Mist
  static const WeatherConditionData fog = WeatherConditionData(
    type: WeatherConditionType.fog,
    key: 'fog',
    nameEn: 'Misty & Foggy',
    nameAm: 'ጭጋጋማ',
    nameOm: 'Hurrii fi Hurraata',
    imagePath: '$_basePath/weather_fog.jpg',
    supabaseUrl: '$_supabaseBase/weather_fog.jpg',
    icon: Icons.grain_rounded,
    gradientColors: [
      Color(0xFF475569),
      Color(0xFF64748B),
      Color(0xFF334155),
    ],
    accentColor: Color(0xFFCBD5E1),
    badgeColor: Color(0x33CBD5E1),
    shadowColor: Color(0x33334155),
  );

  /// Drizzle & Light Showers
  static const WeatherConditionData drizzle = WeatherConditionData(
    type: WeatherConditionType.drizzle,
    key: 'drizzle',
    nameEn: 'Light Drizzle',
    nameAm: 'ካፊያ ዝናብ',
    nameOm: 'Tifa Booranaa',
    imagePath: '$_basePath/weather_rainy.jpg',
    supabaseUrl: '$_supabaseBase/weather_rainy.jpg',
    icon: Icons.grain_rounded,
    gradientColors: [
      Color(0xFF0F766E),
      Color(0xFF0E7490),
      Color(0xFF1E293B),
    ],
    accentColor: Color(0xFF2DD4BF),
    badgeColor: Color(0x332DD4BF),
    shadowColor: Color(0x330F766E),
  );

  /// Rain & Heavy Showers
  static const WeatherConditionData rainy = WeatherConditionData(
    type: WeatherConditionType.rainy,
    key: 'rainy',
    nameEn: 'Rain & Showers',
    nameAm: 'ዝናባማ ወቅት',
    nameOm: 'Rooba fi Hurrii',
    imagePath: '$_basePath/weather_rainy.jpg',
    supabaseUrl: '$_supabaseBase/weather_rainy.jpg',
    icon: Icons.water_drop_rounded,
    gradientColors: [
      Color(0xFF1E293B),
      Color(0xFF0C4A6E),
      Color(0xFF0284C7),
    ],
    accentColor: Color(0xFF38BDF8),
    badgeColor: Color(0x3338BDF8),
    shadowColor: Color(0x4D0C4A6E),
  );

  /// Thunderstorm & Lightning
  static const WeatherConditionData thunderstorm = WeatherConditionData(
    type: WeatherConditionType.thunderstorm,
    key: 'thunderstorm',
    nameEn: 'Thunderstorm & Lightning',
    nameAm: 'ነጎድጓዳማ ዝናብ',
    nameOm: 'Bakakka fi Mandisuu',
    imagePath: '$_basePath/weather_thunderstorm.jpg',
    supabaseUrl: '$_supabaseBase/weather_thunderstorm.jpg',
    icon: Icons.thunderstorm_rounded,
    gradientColors: [
      Color(0xFF0F172A),
      Color(0xFF312E81),
      Color(0xFF581C87),
    ],
    accentColor: Color(0xFFA855F7),
    badgeColor: Color(0x33A855F7),
    shadowColor: Color(0x66312E81),
  );

  /// Highland Frost & Freeze Alert (Cold night Ethiopian highlands)
  static const WeatherConditionData frost = WeatherConditionData(
    type: WeatherConditionType.frost,
    key: 'frost',
    nameEn: 'Highland Frost Alert',
    nameAm: 'የደጋ ውርጭ ማስጠንቀቂያ',
    nameOm: 'Qorra Baddaa',
    imagePath: '$_basePath/weather_frost.jpg',
    supabaseUrl: '$_supabaseBase/weather_frost.jpg',
    icon: Icons.ac_unit_rounded,
    gradientColors: [
      Color(0xFF0C4A6E),
      Color(0xFF0369A1),
      Color(0xFF0284C7),
    ],
    accentColor: Color(0xFFBAE6FD),
    badgeColor: Color(0x33BAE6FD),
    shadowColor: Color(0x4D0369A1),
  );

  /// Windy & Strong Gusts
  static const WeatherConditionData windy = WeatherConditionData(
    type: WeatherConditionType.windy,
    key: 'windy',
    nameEn: 'High Winds & Gusts',
    nameAm: 'ኃይለኛ ንፋስ',
    nameOm: 'Qilleensa Hamaa',
    imagePath: '$_basePath/weather_cloudy.jpg',
    supabaseUrl: '$_supabaseBase/weather_cloudy.jpg',
    icon: Icons.air_rounded,
    gradientColors: [
      Color(0xFF047857),
      Color(0xFF065F46),
      Color(0xFF1E293B),
    ],
    accentColor: Color(0xFF34D399),
    badgeColor: Color(0x3334D399),
    shadowColor: Color(0x33047857),
  );

  /// All supported conditions for simulator and preview
  static const List<WeatherConditionData> allConditions = [
    sunny,
    partlyCloudy,
    cloudy,
    rainy,
    thunderstorm,
    fog,
    frost,
  ];

  /// Resolves any WMO weather code (0 - 99) or description to standard WeatherConditionData
  static WeatherConditionData resolve({
    dynamic weatherCode,
    String? description,
    double? precipitationMm,
    double? windSpeedKmh,
    double? minTempC,
  }) {
    // 1. Highland Frost priority (sub-zero or nocturnal freeze hazard in Dega AEZ)
    if (minTempC != null && minTempC <= 4.0 && (precipitationMm ?? 0) < 1.0) {
      return frost;
    }

    // 2. Gale force wind priority (> 45 km/h)
    if (windSpeedKmh != null && windSpeedKmh >= 45.0) {
      return windy;
    }

    // 3. WMO Numeric Code Parsing
    final codeInt = int.tryParse(weatherCode?.toString() ?? '');
    if (codeInt != null) {
      switch (codeInt) {
        case 0:
        case 1:
          return sunny;
        case 2:
          return partlyCloudy;
        case 3:
        case 4:
          return cloudy;
        case 45:
        case 48:
          return fog;
        case 51:
        case 53:
        case 55:
        case 56:
        case 57:
          return drizzle;
        case 61:
        case 63:
        case 65:
        case 66:
        case 67:
        case 80:
        case 81:
        case 82:
          return rainy;
        case 71:
        case 73:
        case 75:
        case 77:
        case 85:
        case 86:
          return frost;
        case 95:
        case 96:
        case 99:
          return thunderstorm;
        default:
          break;
      }
    }

    // 4. Description string matching
    final desc = (description ?? '').toLowerCase();
    if (desc.contains('thunder') || desc.contains('lightning') || desc.contains('storm')) {
      return thunderstorm;
    }
    if (desc.contains('rain') || desc.contains('shower') || desc.contains('downpour')) {
      return rainy;
    }
    if (desc.contains('drizzle') || desc.contains('mist')) {
      return drizzle;
    }
    if (desc.contains('fog') || desc.contains('haze')) {
      return fog;
    }
    if (desc.contains('frost') || desc.contains('freeze') || desc.contains('snow')) {
      return frost;
    }
    if (desc.contains('partly') || desc.contains('scattered')) {
      return partlyCloudy;
    }
    if (desc.contains('cloud') || desc.contains('overcast')) {
      return cloudy;
    }
    if (desc.contains('wind') || desc.contains('gust')) {
      return windy;
    }

    // 5. Fallback based on precipitation amount
    final rain = precipitationMm ?? 0.0;
    if (rain >= 15.0) return rainy;
    if (rain >= 1.0) return drizzle;

    return sunny;
  }
}

/// WHO Standard UV Index Scale & Protection Guidance
class UvIndexStandards {
  static const Color lowColor = Color(0xFF22C55E); // Green
  static const Color moderateColor = Color(0xFFF59E0B); // Yellow/Amber
  static const Color highColor = Color(0xFFF97316); // Orange
  static const Color veryHighColor = Color(0xFFEF4444); // Red
  static const Color extremeColor = Color(0xFFA855F7); // Violet/Purple

  static Color getColor(double uv) {
    if (uv < 3) return lowColor;
    if (uv < 6) return moderateColor;
    if (uv < 8) return highColor;
    if (uv < 11) return veryHighColor;
    return extremeColor;
  }

  static String getCategory(double uv, String lang) {
    final isAm = lang.toLowerCase() == 'am';
    final isOm = lang.toLowerCase() == 'om';

    if (uv < 3) {
      if (isAm) return 'ዝቅተኛ (ደህንነቱ የተጠበቀ)';
      if (isOm) return 'Gadi Aanaa (Nagaa)';
      return 'Low (Safe)';
    }
    if (uv < 6) {
      if (isAm) return 'መካከለኛ';
      if (isOm) return 'Giddu-galeessa';
      return 'Moderate';
    }
    if (uv < 8) {
      if (isAm) return 'ከፍተኛ ጥንቃቄ';
      if (isOm) return 'Olaanaa';
      return 'High';
    }
    if (uv < 11) {
      if (isAm) return 'በጣም ከፍተኛ';
      if (isOm) return 'Baay\'ee Olaanaa';
      return 'Very High';
    }
    if (isAm) return 'እጅግ በጣም አደገኛ';
    if (isOm) return 'Balaafamaa';
    return 'Extreme';
  }

  static String getAdvice(double uv, String lang) {
    final isAm = lang.toLowerCase() == 'am';
    final isOm = lang.toLowerCase() == 'om';

    if (uv < 3) {
      if (isAm) return 'የፀሐይ መከላከያ አያስፈልግም። ለእርሻ ሥራ አመቺ ነው።';
      if (isOm) return 'Eegumsi aduu hin barbaachisu. Hojii qonnaaf mijaawaa dha.';
      return 'No protection needed. Safe for outdoor field work.';
    }
    if (uv < 6) {
      if (isAm) return 'በቀትር ወቅት ባርኔጣ ያድርጉ እና ጥላ ስር ያርፉ።';
      if (isOm) return 'Guyyaa walakkaa koofiyyaa godhadhaa, gaaddisa jala boqodhaa.';
      return 'Wear a hat and stay in shade near midday.';
    }
    if (uv < 8) {
      if (isAm) return 'በረጅም እጅ ልብስ ይሸፈኑ፤ በቀትር ከፀሐይ ይራቁ።';
      if (isOm) return 'Uffata dheeraa uffadha; aduu saafaa irraa fagaadhaa.';
      return 'Cover up, wear hat/sunglasses. Reduce midday sun exposure.';
    }
    if (uv < 11) {
      if (isAm) return 'ተጨማሪ ጥንቃቄ ያስፈልጋል፤ ቆዳን ከቀጥታ ፀሐይ ይጠብቁ።';
      if (isOm) return 'Eeggannoo cimaa barbaada; gogaa aduu irraa eegaa.';
      return 'Extra protection required. Avoid direct outdoor sun in midday.';
    }
    if (isAm) return 'እጅግ አደገኛ፤ ከቀኑ 5:00 እስከ 9:00 ከቤት ውጭ ሥራ አይመከርም።';
    if (isOm) return 'Baay\'ee balaafamaa; sa\'aatii 5:00-9:00 dirree irratti hin hojjetinaa.';
    return 'Extreme risk! Reschedule heavy field work away from midday hours.';
  }
}
