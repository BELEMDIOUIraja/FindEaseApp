import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';

// Firebase options
import 'firebase_options.dart';

// Providers
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/room_provider.dart';

// ViewModels
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/property_viewmodel.dart';
import 'viewmodel/recommendation_viewmodel.dart';
import 'viewmodel/match_reference_viewmodel.dart';
import 'viewmodel/feedback_viewmodel.dart';

// Services
import 'services/recommendation_config.dart';

// Views
import 'view/login_screen.dart';
import 'view/signup_screen.dart';
import 'view/splash_screen.dart';
import 'view/home_screen.dart';
import 'view/search_screen.dart';
import 'view/property_details_screen.dart';
import 'view/profile_screen.dart';
import 'view/auth_screen.dart';
import 'view/match_reference_view.dart';
import 'view/feedback_view.dart';
import 'view/match_housing_offers_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialiser le système de recommandation
  final bool recommendationInitialized = await RecommendationConfig.initRecommendationSystem();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PropertyViewModel()),
        ChangeNotifierProvider(create: (_) => RecommendationViewModel()),
        ChangeNotifierProvider(create: (_) => MatchReferenceViewModel()),
        ChangeNotifierProvider(create: (_) => FeedbackViewModel()),
      ],
      child: MyApp(recommendationInitialized: recommendationInitialized),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool recommendationInitialized;

  const MyApp({super.key, required this.recommendationInitialized});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FindEase & MatchApp',
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
      locale: localeProvider.locale,
      home: SplashScreen(recommendationInitialized: recommendationInitialized),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/search': (context) => const SearchScreen(),
        '/property-details': (context) => const PropertyDetailsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/auth': (context) => const AuthScreen(),
        '/match-reference': (context) => const MatchReferenceView(),
        '/match-housing-offers': (context) => const MatchHousingOffersView(),
        '/feedback': (context) => const FeedbackView(),
      },
    );
  }
}
