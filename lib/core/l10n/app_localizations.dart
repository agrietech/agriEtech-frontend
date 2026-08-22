import 'package:flutter/material.dart';

/// Multilingual localization support for AgriEtech (English and Amharic only)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'AgriEtech',
      'app_tagline': 'Multi-Hazard Early Warning & Agriculture Advisory System',
      'login': 'Login',
      'register': 'Register',
      'username': 'Username',
      'phone': 'Phone Number',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'reset_password': 'Reset Password',
      'full_name': 'Full Name',
      'email': 'Email Address',
      'logout': 'Logout',
      'dashboard': 'Dashboard',
      'farms': 'My Farms',
      'alerts': 'Alerts',
      'risk_map': 'Risk Map',
      'weather': 'Weather',
      'weather_forecast': 'Weather Forecast',
      'add_farm': 'Add Farm',
      'edit_farm': 'Edit Farm',
      'farm_name': 'Farm Name',
      'crop_type': 'Crop Type',
      'farm_size': 'Farm Size (hectares)',
      'location': 'Location',
      'save': 'Save',
      'cancel': 'Cancel',
      'loading': 'Loading...',
      'error': 'Error',
      'no_data': 'No data available',
      'retry': 'Retry',
      'risk_level': 'Risk Level',
      'low': 'Low',
      'moderate': 'Moderate',
      'high': 'High',
      'critical': 'Critical',
      'drought': 'Drought',
      'flood': 'Flood',
      'locust': 'Locust Swarm',
      'vegetation': 'Vegetation Stress',
      'frost': 'Frost Risk',
      'heat_stress': 'Heat Stress',
      'disease_diagnosis': 'Crop Disease Diagnosis',
      'diagnosis_result': 'Diagnosis Result',
      'take_photo': 'Take Photo',
      'choose_gallery': 'Choose from Gallery',
      'confidence': 'Confidence Score',
      'treatment_plan': 'Recommended Treatment Plan',
      'prevention_tips': 'Prevention Guidelines',
      'sensors': 'IoT Sensors',
      'soil_moisture': 'Soil Moisture',
      'soil_temperature': 'Soil Temperature',
      'battery_level': 'Battery Level',
      'offline_mode': 'Offline Mode',
      'sync_pending': 'Pending Sync Actions',
      'sync_now': 'Sync Now',
      'belg_season': 'Belg Season',
      'kiremt_season': 'Kiremt Season',
      'bega_season': 'Bega Season',
    },
    'am': {
      'app_name': 'አግሪኢቴክ',
      'app_tagline': 'የግብርና አደጋ ቅድመ ማስጠንቀቂያና የምክር አገልግሎት ስርዓት',
      'login': 'ግባ',
      'register': 'ተመዝገብ',
      'username': 'የተጠቃሚ ስም',
      'phone': 'ስልክ ቁጥር',
      'password': 'የይለፍ ቃል',
      'forgot_password': 'የይለፍ ቃል ረሱ?',
      'reset_password': 'የይለፍ ቃል ቀይር',
      'full_name': 'ሙሉ ስም',
      'email': 'ኢሜይል አድራሻ',
      'logout': 'ውጣ',
      'dashboard': 'መቆጣጠሪያ ሰሌዳ',
      'farms': 'የእኔ እርሻዎች',
      'alerts': 'ማስጠንቀቂያዎች',
      'risk_map': 'የአደጋ ካርታ',
      'weather': 'የአየር ሁኔታ',
      'weather_forecast': 'የአየር ሁኔታ ትንበያ',
      'add_farm': 'እርሻ ጨምር',
      'edit_farm': 'እርሻ አስተካክል',
      'farm_name': 'የእርሻ ስም',
      'crop_type': 'የሰብል አይነት',
      'farm_size': 'የእርሻ መጠን (ሄክታር)',
      'location': 'አካባቢ',
      'save': 'አስቀምጥ',
      'cancel': 'ሰርዝ',
      'loading': 'በመጫን ላይ...',
      'error': 'ስህተት',
      'no_data': 'ምንም መረጃ የለም',
      'retry': 'እንደገና ሞክር',
      'risk_level': 'የአደጋ ደረጃ',
      'low': 'ዝቅተኛ',
      'moderate': 'መካከለኛ',
      'high': 'ከፍተኛ',
      'critical': 'ወሳኝ',
      'drought': 'ድርቅ',
      'flood': 'የጎርፍ አደጋ',
      'locust': 'የአንበጣ መንጋ',
      'vegetation': 'የእፅዋት ጭንቀት (NDVI)',
      'frost': 'የውርጭ አደጋ',
      'heat_stress': 'ከፍተኛ ሙቀት',
      'disease_diagnosis': 'የሰብል በሽታ ምርመራ',
      'diagnosis_result': 'የምርመራ ውጤት',
      'take_photo': 'ፎቶ አንሳ',
      'choose_gallery': 'ከማዕከለ-ስዕላት ምረጥ',
      'confidence': 'የእርግጠኝነት ደረጃ',
      'treatment_plan': 'የሚመከር የህክምና እቅድ',
      'prevention_tips': 'የመከላከያ መመሪያዎች',
      'sensors': 'የአይኦቲ ዳሳሾች',
      'soil_moisture': 'የአፈር እርጥበት',
      'soil_temperature': 'የአፈር ሙቀት',
      'battery_level': 'የባትሪ መጠን',
      'offline_mode': 'ያለ ኢንተርኔት (ኦፍላይን)',
      'sync_pending': 'ያልተላኩ መረጃዎች',
      'sync_now': 'አሁን አመሳስል',
      'belg_season': 'የበልግ ወቅት',
      'kiremt_season': 'የክረምት ወቅት',
      'bega_season': 'የበጋ ወቅት',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'am'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
