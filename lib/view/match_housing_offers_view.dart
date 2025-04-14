
// lib/view/match_housing_offers_view.dart
import 'package:flutter/material.dart';

class MatchHousingOffersView extends StatelessWidget {
  const MatchHousingOffersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3E9),
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Housing Offers',
              style: TextStyle(
                fontSize: 24,
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
              child: const Center(
                child: Icon(
                  Icons.star,
                  color: Colors.green,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset(
              'image/match.jpg',
              // <-- Mets ici le chemin de ton image
              fit: BoxFit.cover,
            ),

          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.8), // Peut être ajusté : 0.5, 0.6, etc.
            ),
          ),

          // Contenu scrollable au-dessus de l'image
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHousingOffer(
                  context,
                  imageUrl: 'image/RIAD11.PNG',
                  price: 'dh120/night',
                  walkTime: '15 min walk',
                  zone: 'Fes Zone',
                ),
                const SizedBox(height: 20),
                _buildHousingOffer(
                  context,
                  imageUrl: 'image/maison11.PNG',
                  price: 'dh90/night',
                  walkTime: '10 min walk',
                  zone: 'Casa Zone',
                ),
                const SizedBox(height: 20),
                _buildHousingOffer(
                  context,
                  imageUrl: 'image/VILLA21.PNG',
                  price: 'dh150/night',
                  walkTime: '5 min walk',
                  zone: 'Rabat Zone',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Icône Accueil (active)
            _buildNavItem(
              context,
              Icons.home,
              isActive: true,
              onTap: () {},
            ),

            // Icône Recherche
            _buildNavItem(
              context,
              Icons.search,
              isActive: false,
              onTap: () {},
            ),

            // Icône Profil
            _buildNavItem(
              context,
              Icons.person,
              isActive: false,
              onTap: () {
                Navigator.pushNamed(context, '/feedback');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHousingOffer(
      BuildContext context, {
        required String imageUrl,
        required String price,
        required String walkTime,
        required String zone,
      }) {
    return GestureDetector(
      onTap: () {
        // Naviguer vers les détails du logement (si nécessaire)
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du logement
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                // Si l'image ne se charge pas, utiliser un placeholder
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.home,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Informations sur le logement
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const Text(
                        ' • ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.brown,
                        ),
                      ),
                      Text(
                        walkTime,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    zone,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.brown.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context,
      IconData icon, {
        required bool isActive,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE67E22).withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFFE67E22) : Colors.grey,
          size: 28,
        ),
      ),
    );
  }
}