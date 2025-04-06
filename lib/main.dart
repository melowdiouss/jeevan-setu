import 'package:flutter/material.dart';
import 'package:jeevansetu/screens/splash_screen.dart';
import 'package:jeevansetu/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'screens/agriculture_screen.dart';
import 'screens/education_screen.dart';
import 'screens/healthcare_screen.dart';
import 'screens/financial_assistance_screen.dart';
import 'screens/government_schemes_screen.dart';
import 'screens/home_page.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'services/firebase_service.dart';
import 'services/remote_config_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Remote Config
  final remoteConfigService = RemoteConfigService();
  await remoteConfigService.initialize();
  
  // Only initialize Crashlytics on non-web platforms
  if (!kIsWeb) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jeevan Setu',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const AppInitializer(),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/education': (context) => const EducationScreen(studentName:'',age:0, grade:'', stream: '',subjects:[]),
        '/healthcare': (context) => const HealthcareScreen(),
        '/agriculture': (context) => const AgricultureScreen(),
        '/financial': (context) => const FinancialPage(),
        '/government': (context) => const GovernmentPage(),
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }

    return const AuthWrapper();
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData) {
          return const HomePage();
        }

        return const LoginScreen();
      },
    );
  }
}