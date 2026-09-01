import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active application language code provider ('en', 'am', 'om', 'ti', 'so')
final appLocaleProvider = StateProvider<String>((ref) => 'en');

/// Multilingual localization engine for AgriEtech Platform
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
      // General & Auth
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
      'role': 'Role',
      'security': 'Security',
      'profile': 'Profile',
      'signOut': 'Sign Out',
      'sign_out': 'Sign Out',
      'welcomeBack': 'Welcome back,',
      'welcome_back': 'Welcome back,',
      'services': 'Services',
      'scanCrop': 'Scan Crop',
      'scan_crop': 'Scan Crop',
      'voiceAi': 'Voice AI',
      'voice_ai': 'Voice AI',
      'online': 'ONLINE',
      'offline': 'OFFLINE',
      'jurisdiction': 'Jurisdiction',
      'phoneNumber': 'Phone Number',
      'phone_number': 'Phone Number',
      'emailAddress': 'Email Address',
      'email_address': 'Email Address',
      'language': 'Preferred Language',
      'language_toggle': 'EN | አማ',
      'switch_to_amharic': 'ቀይር ወደ አማርኛ',
      'switch_to_english': 'Switch to English',
      'applyForRole': 'Apply for Role Upgrade',
      'apply_for_role': 'Apply for Role Upgrade',
      'changePassword': 'Change Password',
      'change_password': 'Change Password',
      'appVersion': 'AgriEtech Platform v2.0',
      'app_version': 'AgriEtech Platform v2.0',

      // Navigation & Dashboard
      'home': 'Home',
      'dashboard': 'Dashboard',
      'farms': 'My Farms',
      'alerts': 'Alerts',
      'risk_map': 'Risk Map',
      'risks': 'Risks',
      'disasters': 'Disasters',
      'sensors': 'IoT Sensors',
      'boundaries': 'Boundaries',
      'analytics': 'Analytics',
      'ussd': 'USSD *212#',
      'assistant': 'AI Assistant',
      'weather': 'Weather',
      'weather_forecast': 'Weather Forecast',
      'today': 'Today',
      '7_day_forecast': '7-Day Forecast',
      'temperature_trend': 'Temperature Trend',
      'rainfall': 'Rainfall',
      'rain': 'Rain',
      'humidity': 'Humidity',
      'wind': 'Wind Speed',
      'evapotranspiration_title': 'Crop Evapotranspiration (ET₀) & Water Balance',
      'evapotranspiration_subtitle': 'Agronomic Daily Irrigation Demand',
      'et0_ref': 'Reference ET₀',
      'et0_caption': 'Atmospheric demand',
      'effective_rain': 'Effective Rain',
      'effective_rain_caption': 'Infiltration rate',
      'net_deficit': 'Net Deficit',
      'net_deficit_caption': 'Irrigation need',
      'irrigation_advisory': 'Recommendation: Schedule drip or furrow irrigation within 48h to prevent root zone stress.',
      'status_optimal': 'OPTIMAL',
      'status_watch': 'WATCH',
      'status_stress': 'STRESS',

      // Farm & Management
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

      // Risk & Early Warning
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
      'seismology': 'Earthquake & Faults',
      'soil_degradation': 'Soil Loss (RUSLE)',
      'landslides': 'Landslide Stability',
      'volcano': 'Volcanic Heat',

      // Remote Sensing & Radar
      'sar_radar_active': 'SAR Radar Active',
      'sar_radar_desc': 'Optical Sentinel-2 obscured by monsoon clouds; soil moisture calibrated via C-Band microwave radar.',
      'sar_radar_badge': 'Sentinel-1 SAR Active',

      // Disease Diagnosis
      'disease_diagnosis': 'Crop Disease Diagnosis',
      'diagnosis_result': 'Diagnosis Result',
      'take_photo': 'Take Photo',
      'choose_gallery': 'Choose from Gallery',
      'change_photo': 'Change Photo',
      'ready_for_scan': 'Ready for AI Scan',
      'scan_leaf_title': 'Scan Crop Leaf with AI',
      'confidence': 'Confidence Score',
      'treatment_plan': 'Recommended Treatment Plan',
      'prevention_tips': 'Prevention Guidelines',
      'cooperative_advice': 'Primary Cooperative Sourcing',
      'da_escalation': 'DA Review Escalation',

      // Voice AI Assistant
      'ask_voice_placeholder': 'Ask in Amharic or English (e.g. soil acidity, weather)...',
      'prompt_soil_acidity': 'How do I treat acidic soil with Agricultural Lime (ኖራ)?',
      'prompt_teff_rust': 'What are the symptoms and cure for Teff rust?',
      'prompt_weather_forecast': 'What is the rainfall forecast for this week?',
      'listening': 'Listening...',
      'speak_prompt': 'Hold to Speak or Type below',

      // Sensors & Seasons
      'soil_moisture': 'Soil Moisture',
      'soil_temperature': 'Soil Temperature',
      'battery_level': 'Battery Level',
      'offline_mode': 'Offline Mode',
      'sync_pending': 'Pending Sync Actions',
      'sync_now': 'Sync Now',
      'belg_season': 'Belg Season',
      'kiremt_season': 'Kiremt Season',
      'bega_season': 'Bega Season',
      'meher_season': 'Meher Season',
    },
    'am': {
      // General & Auth
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
      'role': 'የስራ ድርሻ',
      'security': 'ደህንነት',
      'profile': 'መገለጫ',
      'signOut': 'ውጣ',
      'sign_out': 'ውጣ',
      'welcomeBack': 'እንኳን ደህና መጡ፣',
      'welcome_back': 'እንኳን ደህና መጡ፣',
      'services': 'አገልግሎቶች',
      'scanCrop': 'ሰብል ይቃኙ',
      'scan_crop': 'ሰብል ይቃኙ',
      'voiceAi': 'የድምጽ ረዳት',
      'voice_ai': 'የድምጽ ረዳት',
      'online': 'በመስመር ላይ',
      'offline': 'ከመስመር ውጭ',
      'jurisdiction': 'የስራ ክልል',
      'phoneNumber': 'ስልክ ቁጥር',
      'phone_number': 'ስልክ ቁጥር',
      'emailAddress': 'ኢሜይል',
      'email_address': 'ኢሜይል',
      'language': 'ተመራጭ ቋንቋ',
      'language_toggle': 'አማ | EN',
      'switch_to_amharic': 'ወደ አማርኛ ቀይር',
      'switch_to_english': 'ወደ እንግሊዝኛ ቀይር (English)',
      'applyForRole': 'የስራ ድርሻ ማሻሻያ ይጠይቁ',
      'apply_for_role': 'የስራ ድርሻ ማሻሻያ ይጠይቁ',
      'changePassword': 'የይለፍ ቃል ቀይር',
      'change_password': 'የይለፍ ቃል ቀይር',
      'appVersion': 'አግሪኢቴክ መድረክ v2.0',
      'app_version': 'አግሪኢቴክ መድረክ v2.0',

      // Navigation & Dashboard
      'home': 'ዋና ገጽ',
      'dashboard': 'መቆጣጠሪያ ሰሌዳ',
      'farms': 'የእኔ እርሻዎች',
      'alerts': 'ማስጠንቀቂያዎች',
      'risk_map': 'የአደጋ ካርታ',
      'risks': 'አደጋዎች',
      'disasters': 'የተፈጥሮ አደጋዎች',
      'sensors': 'ሴንሰሮች',
      'boundaries': 'ወሰኖች',
      'analytics': 'ትንታኔ',
      'ussd': 'USSD *212#',
      'assistant': 'የAI ረዳት',
      'weather': 'የአየር ሁኔታ',
      'weather_forecast': 'የአየር ሁኔታ ትንበያ',
      'today': 'ዛሬ',
      '7_day_forecast': 'የ7 ቀናት ትንበያ',
      'temperature_trend': 'የሙቀት መጠን አዝማሚያ',
      'rainfall': 'የዝናብ መጠን',
      'rain': 'ዝናብ',
      'humidity': 'እርጥበት',
      'wind': 'የንፋስ ፍጥነት',
      'evapotranspiration_title': 'የሰብል ትነት እና የውሃ ሚዛን (ET₀)',
      'evapotranspiration_subtitle': 'የዕለታዊ የመስኖ ፍላጎት መጠን',
      'et0_ref': 'መነሻ ET₀',
      'et0_caption': 'የከባቢ አየር ፍላጎት',
      'effective_rain': 'ጠቃሚ ዝናብ',
      'effective_rain_caption': 'ወደ አፈር የገባው መጠን',
      'net_deficit': 'የውሃ እጥረት',
      'net_deficit_caption': 'የመስኖ ፍላጎት',
      'irrigation_advisory': 'ምክር፡ የሰብል ሥር እንዳይደርቅ በሚቀጥሉት 48 ሰዓታት ውስጥ መስኖ ያጠጡ።',
      'status_optimal': 'ጥሩ',
      'status_watch': 'ክትትል',
      'status_stress': 'ውጥረት',

      // Farm & Management
      'add_farm': 'እርሻ ጨምር',
      'edit_farm': 'እርሻ አስተካክል',
      'farm_name': 'የእርሻ ስም',
      'crop_type': 'የሰብል አይነት',
      'farm_size': 'የእርሻ ስፋት (በሄክታር)',
      'location': 'አካባቢ',
      'save': 'አስቀምጥ',
      'cancel': 'ሰርዝ',
      'loading': 'በመጫን ላይ...',
      'error': 'ስህተት',
      'no_data': 'ምንም መረጃ የለም',
      'retry': 'እንደገና ሞክር',

      // Risk & Early Warning
      'risk_level': 'የአደጋ ደረጃ',
      'low': 'ዝቅተኛ',
      'moderate': 'መካከለኛ',
      'high': 'ከፍተኛ',
      'critical': 'አስጊ',
      'drought': 'ድርቅ',
      'flood': 'የጎርፍ አደጋ',
      'locust': 'የአንበጣ መንጋ',
      'vegetation': 'የእፅዋት ጭንቀት',
      'frost': 'የውርጭ አደጋ',
      'heat_stress': 'የሙቀት ጭንቀት',
      'seismology': 'የመሬት መንቀጥቀጥ',
      'soil_degradation': 'የአፈር መሸርሸር',
      'landslides': 'የመሬት መንሸራተት',
      'volcano': 'እሳተ ገሞራ',

      // Remote Sensing & Radar
      'sar_radar_active': 'የሳተላይት ራዳር ንቁ ነው',
      'sar_radar_desc': 'የክረምት ደመናን ሰብሮ በሚገባው የSentinel-1 C-Band ራዳር የአፈር እርጥበት በትክክል ተረጋግጧል።',
      'sar_radar_badge': 'Sentinel-1 ራዳር ንቁ ነው',

      // Disease Diagnosis
      'disease_diagnosis': 'የሰብል በሽታ ምርመራ',
      'diagnosis_result': 'የምርመራ ውጤት',
      'take_photo': 'ፎቶ አንሳ',
      'choose_gallery': 'ከማዕከለ-ስዕላት ምረጥ',
      'change_photo': 'ፎቶ ቀይር',
      'ready_for_scan': 'ለAI ምርመራ ዝግጁ ነው',
      'scan_leaf_title': 'የሰብል ቅጠልን በAI ይመርምሩ',
      'confidence': 'የእርግጠኝነት ደረጃ',
      'treatment_plan': 'የሚመከር የህክምና እቅድ',
      'prevention_tips': 'የመከላከያ መመሪያዎች',
      'cooperative_advice': 'ከህብረት ስራ ማህበር የሚገኝ አቅርቦት',
      'da_escalation': 'ለልማት ጣቢያ ባለሙያ ይላክ',

      // Voice AI Assistant
      'ask_voice_placeholder': 'በአማርኛ ወይም በእንግሊዝኛ ይጠይቁ (ምሳሌ፡ የአፈር አሲዳማነት፣ ዝናብ)...',
      'prompt_soil_acidity': 'የአፈር አሲዳማነትን በእርሻ ኖራ እንዴት ማከም እችላለሁ?',
      'prompt_teff_rust': 'የጤፍ ዝገት በሽታ ምልክቶችና ማከሚያው ምንድን ነው?',
      'prompt_weather_forecast': 'የዚህ ሳምንት የዝናብ ትንበያ ምን ይመስላል?',
      'listening': 'በማዳመጥ ላይ...',
      'speak_prompt': 'ተጭነው ይናገሩ ወይም ከታች ይፃፉ',

      // Sensors & Seasons
      'soil_moisture': 'የአፈር እርጥበት',
      'soil_temperature': 'የአፈር ሙቀት',
      'battery_level': 'የባትሪ መጠን',
      'offline_mode': 'ከመስመር ውጭ ሁነታ',
      'sync_pending': 'በመጠባበቅ ላይ ያሉ ማመሳሰሎች',
      'sync_now': 'አሁን አመሳስል',
      'belg_season': 'የበልግ ወቅት',
      'kiremt_season': 'የክረምት ወቅት',
      'bega_season': 'የበጋ ወቅት',
      'meher_season': 'የመኸር ወቅት',
    },
    'om': {
      'app_name': 'AgriEtech',
      'app_tagline': 'Sirna Akeekkachiisa Balaa fi Gorsa Qonnaa',
      'login': 'Seeni',
      'register': 'Galmaa\'i',
      'home': 'Fuula Dura',
      'dashboard': 'Gabaasa',
      'farms': 'Qotiisa',
      'diagnosis': 'Qorannoo',
      'weather': 'Haala Qilleensaa',
      'weather_forecast': 'Raaga Qilleensaa',
      'today': 'Har\'a',
      '7_day_forecast': 'Raaga Guyyoota 7',
      'temperature_trend': 'Haala Hoo\'inaa',
      'rainfall': 'Rooba',
      'rain': 'Rooba',
      'humidity': 'Jiidhinsa',
      'wind': 'Qilleensa',
      'risks': 'Balaawwan',
      'disasters': 'Balaawwan Uumamaa',
      'sensors': 'Sensaroota',
      'boundaries': 'Daangawwan',
      'alerts': 'Akeekkachiisa',
      'analytics': 'Xiinxala',
      'ussd': 'USSD',
      'assistant': 'Gargaaraa',
      'role': 'Gahee Hojii',
      'security': 'Nageenya',
      'profile': 'Eenyummaa',
      'signOut': "Ba'i",
      'sign_out': "Ba'i",
      'welcomeBack': 'Baga nagaan dhufte,',
      'welcome_back': 'Baga nagaan dhufte,',
      'services': 'Tajaajiloota',
      'scanCrop': "Biqiltuu Sakatta'i",
      'scan_crop': "Biqiltuu Sakatta'i",
      'voiceAi': 'Sagalee AI',
      'voice_ai': 'Sagalee AI',
      'online': 'SARARA IRRA',
      'jurisdiction': 'Daangaa Hojii',
      'phoneNumber': 'Lakkoofsa Bilbilaa',
      'phone_number': 'Lakkoofsa Bilbilaa',
      'emailAddress': 'Imeelii',
      'email_address': 'Imeelii',
      'language': 'Afaan Filatame',
      'applyForRole': 'Gahee Hojii Fooyyessuuf Gaafadhu',
      'apply_for_role': 'Gahee Hojii Fooyyessuuf Gaafadhu',
      'changePassword': 'Jijjiirraa Jecha Darbiinsa',
      'change_password': 'Jijjiirraa Jecha Darbiinsa',
      'appVersion': 'Sirna AgriEtech v2.0',
      'app_version': 'Sirna AgriEtech v2.0',
      'add_farm': 'Qotiisa Dabali',
      'save': 'Olkaawi',
      'cancel': 'Haqi',
      'loading': 'Fe\'amaa jira...',
      'error': 'Dogoggora',
      'no_data': 'Odeeffannoon hin jiru',
      'retry': 'Irra deebi\'i',
      'low': 'Gadi Aanaa',
      'moderate': 'Giddu Galeessa',
      'high': 'Olaanaa',
      'critical': 'Balaafamaa',
      'drought': 'Gongee',
      'flood': 'Lolaa',
    },
    'ti': {
      'app_name': 'ኣግሪኢቴክ',
      'login': 'እቶ',
      'home': 'ቀንዲ ገጽ',
      'dashboard': 'ዳሽቦርድ',
      'farms': 'ሕርሻታት',
      'diagnosis': 'ምርመራ',
      'weather': 'ኩነታት ኣየር',
      'weather_forecast': 'ትንበያ ኩነታት ኣየር',
      'today': 'ሎሚ',
      'rainfall': 'ዝናብ',
      'rain': 'ዝናብ',
      'humidity': 'ጥልቂ',
      'wind': 'ንፋስ',
      'risks': 'ሓደጋታት',
      'disasters': 'ሓደጋታት',
      'sensors': 'ሰንሰራት',
      'boundaries': 'ወሰናት',
      'alerts': 'መጠንቀቕታታት',
      'analytics': 'ትንተና',
      'ussd': 'USSD',
      'assistant': 'ሓጋዚ',
      'role': 'ግደ',
      'security': 'ድሕንነት',
      'profile': 'ፕሮፋይል',
      'signOut': 'ውጻእ',
      'sign_out': 'ውጻእ',
      'welcomeBack': 'እንቋዕ ብደሓን መጻእኩም፣',
      'welcome_back': 'እንቋዕ ብደሓን መጻእኩም፣',
      'services': 'ኣገልግሎታት',
      'scanCrop': 'ሰብል መርምር',
      'scan_crop': 'ሰብል መርምር',
      'voiceAi': 'ናይ ድምጺ ሓጋዚ',
      'voice_ai': 'ናይ ድምጺ ሓጋዚ',
      'online': 'ኦንላይን',
      'jurisdiction': 'ናይ ስራሕ ወሰን',
      'phoneNumber': 'ቁጽሪ ስልኪ',
      'phone_number': 'ቁጽሪ ስልኪ',
      'emailAddress': 'ኢሜይል',
      'email_address': 'ኢሜይል',
      'language': 'ዝተመርጸ ቋንቋ',
      'applyForRole': 'ናይ ስራሕ ግደ ምዕባይ ሕተት',
      'apply_for_role': 'ናይ ስራሕ ግደ ምዕባይ ሕተት',
      'changePassword': 'መሕለፊ ቃል ቀይር',
      'change_password': 'መሕለፊ ቃል ቀይር',
      'appVersion': 'ኣግሪኢቴክ ፕላትፎርም v2.0',
      'app_version': 'ኣግሪኢቴክ ፕላትፎርም v2.0',
      'save': 'ኣቐምጥ',
      'cancel': 'ሰርዝ',
      'loading': 'ይጽዕን ኣሎ...',
      'error': 'ጌጋ',
      'no_data': 'ሓበሬታ የለን',
      'retry': 'ደጊምካ ፈትን',
    },
    'so': {
      'app_name': 'AgriEtech',
      'login': 'Gal',
      'home': 'Bogga Hore',
      'dashboard': 'Warbixin',
      'farms': 'Beeraha',
      'diagnosis': 'Baadhitaan',
      'weather': 'Cimilada',
      'weather_forecast': 'Saadaasha Hawada',
      'today': 'Maanta',
      'rainfall': 'Roobka',
      'rain': 'Roob',
      'humidity': 'Qoyaanka',
      'wind': 'Dabayl',
      'risks': 'Khataraha',
      'disasters': 'Masiibooyinka',
      'sensors': 'Dareemayaasha',
      'boundaries': 'Xuduudaha',
      'alerts': 'Digniinaha',
      'analytics': 'Falanqaynta',
      'ussd': 'USSD',
      'assistant': 'Caawiye',
      'role': 'Doorka',
      'security': 'Amniga',
      'profile': 'Xogta Guud',
      'signOut': 'Ka Bax',
      'sign_out': 'Ka Bax',
      'welcomeBack': 'Kusoo dhawaaw,',
      'welcome_back': 'Kusoo dhawaaw,',
      'services': 'Adeegyada',
      'scanCrop': 'Baadh Dalagga',
      'scan_crop': 'Baadh Dalagga',
      'voiceAi': 'Codka AI',
      'voice_ai': 'Codka AI',
      'online': 'KHADKA',
      'jurisdiction': 'Xadka Shaqada',
      'phoneNumber': 'Lambarka Taleefanka',
      'phone_number': 'Lambarka Taleefanka',
      'emailAddress': 'Iimaylka',
      'email_address': 'Iimaylka',
      'language': 'Luqadda La Doortay',
      'applyForRole': 'Codso Dalacsiin Door',
      'apply_for_role': 'Codso Dalacsiin Door',
      'changePassword': 'Beddel Furaha Sirta',
      'change_password': 'Beddel Furaha Sirta',
      'appVersion': 'Madal AgriEtech v2.0',
      'app_version': 'Madal AgriEtech v2.0',
      'save': 'Kaydi',
      'cancel': 'Jooji',
      'loading': 'Waa la soo shubayaa...',
      'error': 'Khalad',
      'no_data': 'Xog ma jirto',
      'retry': 'Isku day mar kale',
    },
  };

  /// Convert camelCase to snake_case for universal key resolution
  static String _toSnakeCase(String key) {
    return key.replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
      (Match m) => '_${m.group(0)!.toLowerCase()}',
    ).toLowerCase();
  }

  /// Translate key with fallback to snake_case, English, and raw key
  String translate(String key) {
    final lang = locale.languageCode;
    final snakeKey = _toSnakeCase(key);

    return _localizedValues[lang]?[key] ??
        _localizedValues[lang]?[snakeKey] ??
        _localizedValues['en']?[key] ??
        _localizedValues['en']?[snakeKey] ??
        key;
  }

  /// Static translator helper
  static String tr(String key, {String lang = 'en'}) {
    final values = _localizedValues[lang] ?? _localizedValues['en']!;
    final snakeKey = _toSnakeCase(key);

    return values[key] ??
        values[snakeKey] ??
        _localizedValues['en']?[key] ??
        _localizedValues['en']?[snakeKey] ??
        key;
  }
}


class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'am', 'om', 'ti', 'so'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Compatibility alias for legacy AppStrings
typedef AppStrings = AppLocalizations;
