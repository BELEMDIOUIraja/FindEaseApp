import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final TextEditingController _firstNameTextEditingController = TextEditingController();
  final TextEditingController _lastNameTextEditingController = TextEditingController();
  final TextEditingController _cityTextEditingController = TextEditingController();
  final TextEditingController _countryTextEditingController = TextEditingController();
  final TextEditingController _bioTextEditingController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            SizedBox(
              height: 250, // hauteur limitée pour éviter qu'il recouvre tout
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'image/images.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),


                  // Logo en haut à droite
                  Positioned(
                    top: 60,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          'FindEase',
                          style: TextStyle(
                            fontFamily: 'Pacifico',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'home to perfection',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),


                ],
              ),
            ),
            // Formulaire Sign Up
            Container(
              width: double.infinity,
              color: const Color(0xFFFDF5EC),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        "Create an account", style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 16),
                    //Email
                    TextFormField(
                      controller: _emailTextEditingController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    //Password
                    TextFormField(
                      controller: _passwordTextEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      validator: (valuePassword) {
                        if (valuePassword == null || valuePassword.length < 6) {
                          return "Password must be at least 6 characters.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    //First Name
                    TextFormField(
                      controller: _firstNameTextEditingController,
                      decoration: InputDecoration(
                        hintText: ' first name',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      validator: (text) {
                        if (text!.isEmpty) {
                          return "Please write your first name";
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),
                    //LastName
                    TextFormField(
                      controller: _lastNameTextEditingController,
                      decoration: InputDecoration(
                        hintText: ' last name',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      validator: (text) {
                        if (text!.isEmpty) {
                          return "Please write your last name";
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),
                    //city
                    TextFormField(
                      controller: _cityTextEditingController,
                      decoration: InputDecoration(
                        hintText: ' city',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      validator: (text) {
                        if (text!.isEmpty) {
                          return "Please write your city name";
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),
                    //Country
                    TextFormField(
                      controller: _countryTextEditingController,
                      decoration: InputDecoration(
                        hintText: ' country',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      validator: (text) {
                        if (text!.isEmpty) {
                          return "Please write your country name";
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),
                    //Bio
                    TextFormField(
                      controller: _bioTextEditingController,
                      decoration: InputDecoration(
                        hintText: ' bio',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      maxLines: 4,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),


                    const SizedBox(height: 20),

                    // Bouton Sign Up
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final email = _emailTextEditingController.text.trim();
                            final password = _passwordTextEditingController.text.trim();
                            final firstName = _firstNameTextEditingController.text.trim();
                            final lastName = _lastNameTextEditingController.text.trim();
                            final city = _cityTextEditingController.text.trim();
                            final country = _countryTextEditingController.text.trim();
                            final bio = _bioTextEditingController.text.trim();

                            try {
                              // 🔐 Création du compte Firebase Auth
                              UserCredential userCredential = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(email: email, password: password);

                              // ☁️ Ajout dans Firestore (collection 'users')
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userCredential.user!.uid)
                                  .set({
                                'email': email,
                                'firstName': firstName,
                                'lastName': lastName,
                                'city': city,
                                'country': country,
                                'bio': bio,
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("✅ Compte et données enregistrés !")),
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("❌ Erreur : ${e.toString()}")),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text("Sign up"),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),


          ],
        ),

      ),
    );
  }

}
