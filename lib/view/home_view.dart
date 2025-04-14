// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/recommendation_viewmodel.dart';
import '../widgets/recommendations_section.dart';
import '../widgets/world_cup_recommendations.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isLoading = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final recommendationViewModel = Provider.of<RecommendationViewModel>(context, listen: false);

    try {
      // Si l'utilisateur est connecté, charger les recommandations personnalisées
      if (authViewModel.isLoggedIn) {
        await recommendationViewModel.loadAllRecommendations(authViewModel.currentUser!.uid);
      } else {
        // Sinon, charger uniquement les propriétés populaires
        await recommendationViewModel.loadPopularProperties();
      }
    } catch (e) {
      // Gérer les erreurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des recommandations: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final recommendationViewModel = Provider.of<RecommendationViewModel>(context, listen: false);

    // Effacer les erreurs précédentes
    recommendationViewModel.clearError();

    if (authViewModel.isLoggedIn) {
      await recommendationViewModel.refreshAll(authViewModel.currentUser!.uid);
    } else {
      await recommendationViewModel.loadPopularProperties();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FindEase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _onRefresh,
            child: ListView(
              children: [
                // Bannière de bienvenue
                _buildWelcomeBanner(authViewModel),

                // Section Coupe du Monde 2030
                if (authViewModel.isLoggedIn)
                  WorldCupRecommendations(
                    userId: authViewModel.currentUser!.uid,
                  ),

                // Recommandations personnalisées (si l'utilisateur est connecté)
                if (authViewModel.isLoggedIn)
                  RecommendationsSection(
                    userId: authViewModel.currentUser!.uid,
                    title: 'Recommandé pour vous',
                    type: RecommendationType.personalized,
                    emptyMessage: 'Consultez plus de propriétés pour obtenir des recommandations personnalisées',
                  ),

                // Propriétés populaires (pour tous les utilisateurs)
                RecommendationsSection(
                  userId: authViewModel.isLoggedIn ? authViewModel.currentUser!.uid : 'guest',
                  title: 'Les plus populaires',
                  type: RecommendationType.popular,
                  emptyMessage: 'Aucune propriété populaire disponible pour le moment',
                ),

                // Carte de message pour la Coupe du Monde 2030
                if (!authViewModel.isLoggedIn)
                  _buildWorldCupPromotionCard(),

                // Section d'exploration par type
                _buildExploreByTypeSection(),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeBanner(AuthViewModel authViewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            authViewModel.isLoggedIn
                ? 'Bonjour, ${authViewModel.currentUser!.displayName ?? "voyageur"} 👋'
                : 'Bienvenue sur FindEase 👋',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            authViewModel.isLoggedIn
                ? 'Découvrez des hébergements adaptés à vos préférences'
                : 'Trouvez l\'hébergement parfait pour votre prochain voyage',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (!authViewModel.isLoggedIn)
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/auth'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Se connecter pour des recommandations personnalisées'),
            ),
        ],
      ),
    );
  }

  Widget _buildWorldCupPromotionCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'image/world_cup_2030_logo.png',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Préparez-vous pour la Coupe du Monde 2030',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Trouvez les meilleurs hébergements près des stades au Maroc, en Espagne et au Portugal pour la Coupe du Monde FIFA 2030.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/auth'),
              child: const Text('Créer un compte pour voir les offres'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreByTypeSection() {
    final propertyTypes = [
      {'type': 'Villa', 'icon': Icons.villa},
      {'type': 'Appartement', 'icon': Icons.apartment},
      {'type': 'Maison', 'icon': Icons.home},
      {'type': 'Chambre d\'hôte', 'icon': Icons.bed},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            'Explorer par type',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          childAspectRatio: 1.5,
          children: propertyTypes.map((item) {
            return Card(
              margin: const EdgeInsets.all(4),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/search',
                    arguments: {'propertyType': item['type']},
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['type'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}