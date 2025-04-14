// lib/view/recommendations_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/property.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/recommendation_viewmodel.dart';
import '../widgets/property_card.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({Key? key}) : super(key: key);

  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final recommendationViewModel = Provider.of<RecommendationViewModel>(context, listen: false);

    if (authViewModel.currentUser != null) {
      // Si l'utilisateur est connecté, charger les recommandations personnalisées
      await recommendationViewModel.loadAllRecommendations(authViewModel.currentUser!.uid);
    } else {
      // Sinon, charger uniquement les propriétés populaires
      await recommendationViewModel.loadPopularProperties();
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadData();

    setState(() {
      _isRefreshing = false;
    });
  }

  String _getRecommendationTitle(String source) {
    switch (source) {
      case 'personal':
        return 'Recommandations personnalisées';
      case 'preferences':
        return 'Basé sur vos préférences';
      case 'popular':
        return 'Propriétés populaires';
      default:
        return 'Recommandations pour vous';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommandations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
        ],
      ),
      body: Consumer2<AuthViewModel, RecommendationViewModel>(
        builder: (context, authViewModel, recommendationViewModel, child) {
          final user = authViewModel.currentUser;
          final recommendationSource =
          recommendationViewModel.personalizedRecommendations.isNotEmpty
              ? 'personal'
              : 'popular';

          if (recommendationViewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des recommandations...'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              children: [
                // Message de connexion pour les utilisateurs non connectés
                if (user == null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Connectez-vous pour obtenir des recommandations personnalisées',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Se connecter'),
                        ),
                      ],
                    ),
                  ),

                // Section des recommandations
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getRecommendationTitle(recommendationSource),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _handleRefresh,
                      ),
                    ],
                  ),
                ),

                // Liste des recommandations
                if (recommendationViewModel.personalizedRecommendations.isEmpty &&
                    recommendationViewModel.popularProperties.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Aucune recommandation disponible pour le moment.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: user != null
                          ? recommendationViewModel.personalizedRecommendations.length
                          : recommendationViewModel.popularProperties.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final property = user != null
                            ? recommendationViewModel.personalizedRecommendations[index]
                            : recommendationViewModel.popularProperties[index];

                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: SizedBox(
                            width: 280,
                            child: PropertyCard(
                              property: property,
                              userId: user?.uid ?? 'guest',
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Propriétés similaires (si disponibles)
                if (user != null && recommendationViewModel.similarProperties.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text(
                      'Propriétés similaires à votre dernière visite',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendationViewModel.similarProperties.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final property = recommendationViewModel.similarProperties[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: SizedBox(
                            width: 280,
                            child: PropertyCard(
                              property: property,
                              userId: user.uid,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Explorer par catégorie
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Text(
                    'Explorer par catégorie',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: ['Villa', 'Appartement', 'Maison', 'Chambre d\'hôte']
                        .map((category) => InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/search',
                          arguments: {'propertyType': category},
                        );
                      },
                      child: Card(
                        child: Center(
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}