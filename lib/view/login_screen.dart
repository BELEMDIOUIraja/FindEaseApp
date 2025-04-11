import 'package:flutter/material.dart';
import 'package:untitled/view/signup_screen.dart';
import 'signin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
      // Background Image
      Positioned.fill(
      child: Image.asset(
        'image/images (2).jpg', // Remplacez par le chemin de votre image
        fit: BoxFit.cover,
      ),
    ),
    // Logo et texte en haut à droite
    Positioned(
      top: 60,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'FindEase',
              style: TextStyle(
                fontFamily: 'Pacifico', // Ici on utilise la police
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              )

          ),
          Text(
            'home to perfection',
            style: TextStyle(
              fontFamily: 'Poppins', // Police Poppins
              fontSize: 16,
              color: Colors.white,
            ),

          ),
        ],
      ),
    ),
    // Bouton en bas
      Positioned(
        bottom: 40,
        left: 20,
        right: 20,
        child: Column(
          children: [
            // Bouton Sign In
            SizedBox(
            width: double.infinity,
            child: ElevatedButton(
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ) ,
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Bouton Sign Up
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
            'Sign Up',
            style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
              ),
            ),
        ],
          ),

      );

  }
}

