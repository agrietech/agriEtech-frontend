import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'AgriEtech',
      'login': 'Login',
      'register': 'Register',
      'username': 'Username',
      'phone': 'Phone Number',
      'password': 'Password',
      'full_name': 'Full Name',
      'email': 'Email Address',
      'logout': 'Logout',
      'dashboard': 'Dashboard',
      'farms': 'My Farms',
      'alerts': 'Alerts',
      'risk_map': 'Risk Map',
      'weather': 'Weather',
      'add_farm': 'Add Farm',
      'farm_name': 'Farm Name',
      'crop_type': 'Crop Type',
      'farm_size': 'Farm Size (hectares)',
      'location': 'Location',
      'save': 'Save',
      'cancel': 'Cancel',
      'loading': 'Loading...',
      'error': 'Error',
      'no_data': 'No data available',
      'risk_level': 'Risk Level',
      'low': 'Low',
      'moderate': 'Moderate',
      'high': 'High',
      'critical': 'Critical',
    },
    'am': {
      'app_name': 'አግሪኢቴክ',
      'login': 'ግባ',
      'register': 'ተመዝገብ',
      'username': 'የተጠቃሚ ስም',
      'phone': 'ስልክ ቁጥር',
      'password': 'የይለፍ ቃል',
      'full_name': 'ሙሉ ስም',
      'email': 'ኢሜይል አድራሻ',
      'logout': 'ውጣ',
      'dashboard': 'መቆጣጠሪያ ሰሌዳ',
      'farms': 'የእኔ እርሻዎች',
      'alerts': 'ማስጠንቀቂያዎች',
      'risk_map': 'የአደጋ ካርታ',
      'weather': 'የአየር ሁኔታ',
      'add_farm': 'እርሻ ጨምር',
      'farm_name': 'የእርሻ ስም',
      'crop_type': 'የሰብል አይነት',
      'farm_size': 'የእርሻ መጠን (ሄክታር)',
      'location': 'አካባቢ',
      'save': 'አስቀምጥ',
      'cancel': 'ሰርዝ',
      'loading': 'በመጫን ላይ...',
      'error': 'ስህተት',
      'no_data': 'ምንም መረጃ የለም',
      'risk_level': 'የአደጋ ደረጃ',
      'low': 'ዝቅተኛ',
      'moderate': 'መካከለኛ',
      'high': 'ከፍተኛ',
      'critical': 'ወሳኝ',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
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
