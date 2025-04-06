import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  static const String _welcomeMessageKey = 'welcome_message';
  static const String _appVersionKey = 'app_version';
  static const String _maintenanceModeKey = 'maintenance_mode';
  static const String _enableCoursesKey = 'enable_courses';
  static const String _enableScholarshipsKey = 'enable_scholarships';
  static const String _enableStudyMaterialsKey = 'enable_study_materials';
  static const String _availableLanguagesKey = 'available_languages';
  static const String _translationsKey = 'translations';

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await _remoteConfig.setDefaults({
        _welcomeMessageKey: 'Welcome to Jeevan Setu',
        _appVersionKey: '1.0.0',
        _maintenanceModeKey: false,
        _enableCoursesKey: true,
        _enableScholarshipsKey: true,
        _enableStudyMaterialsKey: true,
        _availableLanguagesKey: {
          'languages': [
            {'code': 'en', 'name': 'English'},
            {'code': 'hi', 'name': 'Hindi'},
            {'code': 'bn', 'name': 'Bengali'},
            {'code': 'ta', 'name': 'Tamil'},
            {'code': 'te', 'name': 'Telugu'},
            {'code': 'mr', 'name': 'Marathi'},
            {'code': 'gu', 'name': 'Gujarati'},
            {'code': 'kn', 'name': 'Kannada'},
            {'code': 'ml', 'name': 'Malayalam'},
            {'code': 'pa', 'name': 'Punjabi'},
          ],
        },
        _translationsKey: {
          'en': {
            'welcome': 'Welcome',
            'login': 'Login',
            'signup': 'Sign Up',
            'email': 'Email',
            'password': 'Password',
            'forgot_password': 'Forgot Password?',
            'submit': 'Submit',
            'cancel': 'Cancel',
            'error': 'Error',
            'success': 'Success',
            'loading': 'Loading...',
            'retry': 'Retry',
            'education': 'Education',
            'healthcare': 'Healthcare',
            'agriculture': 'Agriculture',
            'financial': 'Financial',
            'government': 'Government',
            'settings': 'Settings',
            'profile': 'Profile',
            'logout': 'Logout',
            'language': 'Language',
            'select_language': 'Select Language',
          },
          'hi': {
            'welcome': 'स्वागत है',
            'login': 'लॉगिन',
            'signup': 'साइन अप',
            'email': 'ईमेल',
            'password': 'पासवर्ड',
            'forgot_password': 'पासवर्ड भूल गए?',
            'submit': 'जमा करें',
            'cancel': 'रद्द करें',
            'error': 'त्रुटि',
            'success': 'सफल',
            'loading': 'लोड हो रहा है...',
            'retry': 'पुनः प्रयास करें',
            'education': 'शिक्षा',
            'healthcare': 'स्वास्थ्य सेवा',
            'agriculture': 'कृषि',
            'financial': 'वित्तीय',
            'government': 'सरकार',
            'settings': 'सेटिंग्स',
            'profile': 'प्रोफ़ाइल',
            'logout': 'लॉग आउट',
            'language': 'भाषा',
            'select_language': 'भाषा चुनें',
          },
        },
      });

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Error initializing Remote Config: $e');
    }
  }

  String get welcomeMessage => _remoteConfig.getString(_welcomeMessageKey);
  String get appVersion => _remoteConfig.getString(_appVersionKey);
  bool get maintenanceMode => _remoteConfig.getBool(_maintenanceModeKey);
  bool get enableCourses => _remoteConfig.getBool(_enableCoursesKey);
  bool get enableScholarships => _remoteConfig.getBool(_enableScholarshipsKey);
  bool get enableStudyMaterials => _remoteConfig.getBool(_enableStudyMaterialsKey);
  Map<String, dynamic> get availableLanguages => _remoteConfig.getValue(_availableLanguagesKey).asString() as Map<String, dynamic>;
  Map<String, dynamic> get translations => _remoteConfig.getValue(_translationsKey).asString() as Map<String, dynamic>;

  RemoteConfigValue getValue(String key) {
    return _remoteConfig.getValue(key);
  }

  Future<void> refreshConfig() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Error refreshing Remote Config: $e');
    }
  }
} 