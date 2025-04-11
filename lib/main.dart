import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/view/login_screen.dart';
import 'package:untitled/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ce fichier a été généré automatiquement



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FindEase',
      initialRoute: '/',
      routes: {
        '/':(context)=>SplashScreen(),
        '/login_screen.dart':(context)=>LoginScreen(),
      },
    );
  }
}



