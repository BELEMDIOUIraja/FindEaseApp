// lib/widgets/world_cup_recommendations.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/property.dart';
import '../viewmodel/recommendation_viewmodel.dart';
import '../services/recommendation_config.dart';

class WorldCupRecommendations extends StatefulWidget {
  final String userId;

  const WorldCupRecommendations({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _WorldCupRecommendationsState createState() => _WorldCupRecommendationsState();
}

class _WorldCupRecommendationsState extends State<WorldCupRecommendations> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCountry;
  String? _selectedStadium;

  @override
  void initState() {
    super.initState();

    // Configurer les onglets pour les pays hôtes
    final hostCountries = RecommendationConfig.WORLD_CUP_INFO['hostCountries'] as List<dynamic>;
    _tabController = TabController(length: hostCountries.length, vsync: this);

    // Sélectionner le premier pays par défaut
    _selectedCountry = hostCountries.first as String?;

    // Charger les recommandations pour le premier pays
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorldCupRecommendations();
    });

    // Écouter les changements d'onglets
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedCountry = hostCountries[_tabController.index] as String?;
          _selectedStadium = null; // Réinitialiser le stade sélectionné
        });
        _loadWorldCupRecommendations();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWorldCupRecommendations() async {
    final viewModel = Provider.of<RecommendationViewModel>(context, listen: false);

    await viewModel.loadWorldCupRecommendations(
      widget.userId,
      hostCountry: _selectedCountry,
      stadiumNearby: _selectedStadium,
    );
  }

  void _selectStadium(String stadium) {
    setState(() {
      _selectedStadium = stadium;
    });
    _loadWorldCupRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    final hostCountries = RecommendationConfig.WORLD_CUP_INFO['hostCountries'] as List<dynamic>;
    final mainStadiums = RecommendationConfig.WORLD_CUP_INFO['mainStadiums'] as Map<String, dynamic>;

    // Stadiums for the selected country
    List<String> stadiums = [];
    if (_selectedCountry != null && mainStadiums.containsKey(_selectedCountry)) {
      stadiums = List<String>.from(mainStadiums[_selectedCountry] ?? []);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et logo de la Coupe du monde
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/world_cup_2030_logo.png',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Coupe du Monde FIFA 2030',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Onglets pour les pays hôtes
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Theme.of(context).primaryColor,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelPadding: const EdgeInsets.symmetric(horizontal: 20),
            tabs: hostCountries.map((country) =>
                Tab(text: country.toString())
            ).toList(),
          ),

          const SizedBox(height: 16),

          // Filtres des stades
          if (stadiums.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Option "Tous les stades"
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Tous les stades'),
                      selected: _selectedStadium == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedStadium = null;
                        });
                        _loadWorldCupRecommendations();
                      },
                    ),
                  ),
                  // Options pour chaque stade
                  ...stadiums.map((stadium) =>
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(stadium),
                          selected: _selectedStadium == stadium,
                          onSelected: (_) => _selectStadium(stadium),
                        ),
                      )
                  ).toList(),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Liste des propriétés recommandées
          Consumer<RecommendationViewModel>(
            builder: (context, viewModel, child) {
              final recommendations = viewModel.worldCupRecommendations;
              final isLoading = viewModel.isLoadingWorldCup;

              if (isLoading && recommendations.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (recommendations.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.sports_soccer,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun logement disponible pour ${_selectedCountry ?? 'la Coupe du Monde'} '
                              '${_selectedStadium != null ? 'près du stade $_selectedStadium' : ''}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedStadium == null
                                  ? 'Hébergements au ${_selectedCountry}'
                                  : 'Près du stade $_selectedStadium',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recommendations.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final property = recommendations[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _WorldCupPropertyCard(
                              property: property,
                              userId: widget.userId,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Carte de propriété stylisée pour la Coupe du Monde
class _WorldCupPropertyCard extends StatelessWidget {
  final Property property;
  final String userId;

  const _WorldCupPropertyCard({
    Key? key,
    required this.property,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RecommendationViewModel>(context, listen: false);
    final worldCupInfo = property.worldCupInfo;

    // Distance du stade (si disponible)
    String? stadiumDistance;
    if (worldCupInfo != null && worldCupInfo.containsKey('stadiumDistanceKm')) {
      final distance = worldCupInfo['stadiumDistanceKm'];
      if (distance is num) {
        stadiumDistance = '${distance.toStringAsFixed(1)} km du stade';
      }
    }

    // Prix spécial Coupe du Monde (si disponible)
    String? specialBadge;
    if (worldCupInfo != null && worldCupInfo.containsKey('worldCupSpecial') && worldCupInfo['worldCupSpecial'] == true) {
      specialBadge = 'Offre Coupe du Monde';
    }

    return GestureDetector(
      onTap: () {
        // Enregistrer l'interaction
        viewModel.trackPropertyClick(
            userId,
            property.id,
            {'source': 'world_cup_recommendation'}
        );

        // Naviguer vers la page de détails
        Navigator.pushNamed(
            context,
            '/property-details',
            arguments: {'propertyId': property.id}
        );
      },
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badge
            Stack(
              children: [
                Image.network(
                  property.images.first,
                  width: 220,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 220,
                    height: 140,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
                if (specialBadge != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        specialBadge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Informations sur la propriété
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type et ville
                  Row(
                    children: [
                      Text(
                        property.type,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('•'),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location['city'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Titre
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Distance du stade
                  if (stadiumDistance != null)
                    Row(
                      children: [
                        Icon(
                          Icons.sports_soccer,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stadiumDistance,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),

                  // Prix
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${property.price.toStringAsFixed(0)}€',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/ nuit',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}