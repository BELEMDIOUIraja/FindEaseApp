import 'package:flutter/material.dart';
import "dart:async";
import 'package:get/get.dart';

import 'login_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required bool recommendationInitialized});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}




class _SplashScreenState extends State<SplashScreen>
{
  @override
  void initState(){
    super.initState();

    Timer(Duration(seconds: 3),()
    {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "image/image-removebg-preview (1).png",
              height: MediaQuery.of(context).size.height*0.7, // hauteur en pixels
            ), // Ajout d'un espace après l'image







          ],
        ),
      ),
    );

  }
}
