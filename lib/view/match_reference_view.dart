// lib/view/match_reference_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/match_reference_viewmodel.dart';

class MatchReferenceView extends StatelessWidget {
  const MatchReferenceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('image/match.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo et titre en haut avec le drapeau marocain
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'MatchApp',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Petit drapeau marocain
                      Container(
                        width: 30,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.star,
                            color: Colors.green,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Section principale avec le formulaire
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F3E9).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Consumer<MatchReferenceViewModel>(
                    builder: (context, viewModel, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Match Reference',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Input pour la date du match
                          _buildInputField(
                            hintText: 'Match date',
                            onChanged: viewModel.setMatchDate,
                            prefixIcon: Icons.calendar_today,
                          ),
                          const SizedBox(height: 15),

                          // Input pour la zone du match
                          _buildInputField(
                            hintText: 'Match zone',
                            onChanged: viewModel.setMatchZone,
                            prefixIcon: Icons.location_on,
                          ),
                          const SizedBox(height: 15),

                          // Input pour le nom de l'utilisateur
                          _buildInputField(
                            hintText: 'Your name',
                            onChanged: viewModel.setUserName,
                            prefixIcon: Icons.person,
                          ),
                          const SizedBox(height: 15),

                          // Input pour le numéro de téléphone
                          _buildInputField(
                            hintText: 'Phone number',
                            onChanged: viewModel.setPhoneNumber,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone,
                          ),
                          const SizedBox(height: 15),

                          // Input pour le budget maximum
                          _buildInputField(
                            hintText: 'Budget maximum',
                            onChanged: viewModel.setBudget,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.euro,
                          ),
                          const SizedBox(height: 30),

                          // Bouton d'inscription
                          ElevatedButton(
                            onPressed: viewModel.isLoading
                                ? null
                                : () async {
                              final success = await viewModel.submitForm();
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Inscription réussie !'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pushNamed(context, '/match-housing-offers');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              elevation: 3,
                            ),
                            child: viewModel.isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'S\'inscrire',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Affichage des erreurs
                          if (viewModel.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Texte "Coupe du Monde • Maroc 2025" en bas
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Coupe du Monde • Maroc 2025',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.brown.withOpacity(0.6)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: InputBorder.none,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.brown.withOpacity(0.7)) : null,
        ),
        style: const TextStyle(color: Colors.brown),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }
}