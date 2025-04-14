// lib/screens/property_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter/material.dart' show CarouselController;
import '../model/property.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/property_viewmodel.dart';
import '../viewmodel/recommendation_viewmodel.dart';
import '../widgets/recommendations_section.dart';

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({Key? key}) : super(key: key);

  @override
  _PropertyDetailsScreenState createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  String? _viewInteractionId;
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // Mettre à jour la durée de visualisation lorsque l'utilisateur quitte la page
    _updateViewDuration();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Récupérer l'ID de la propriété depuis les arguments
    final Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String propertyId = args['propertyId'];

    // Charger les détails de la propriété
    final propertyViewModel = Provider.of<PropertyViewModel>(context, listen: false);
    await propertyViewModel.loadPropertyDetails(propertyId);

    // Vérifier si la propriété est en favoris
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.isLoggedIn) {
      final recommendationViewModel = Provider.of<RecommendationViewModel>(context, listen: false);
      final isFav = await recommendationViewModel.checkIsFavorite(
          authViewModel.currentUser!.uid,
          propertyId
      );

      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }

      // Enregistrer l'interaction de visualisation
      _trackViewInteraction(authViewModel.currentUser!.uid, propertyId);

      // Charger les propriétés similaires
      await recommendationViewModel.loadSimilarProperties(propertyId);
    }
  }

  Future<void> _trackViewInteraction(String userId, String propertyId) async {
    final recommendationViewModel = Provider.of<RecommendationViewModel>(context, listen: false);
    final interactionId = await recommendationViewModel.trackPropertyView(userId, propertyId);

    if (mounted) {
      setState(() {
        _viewInteractionId = interactionId;
      });
    }
  }

  Future<void> _updateViewDuration() async {
    if (_viewInteractionId == null) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final propertyViewModel = Provider.of<PropertyViewModel>(context, listen: false);
    final recommendationViewModel = Provider.of<RecommendationViewModel>(context, listen: false);

    if (authViewModel.isLoggedIn && propertyViewModel.property != null) {
      await recommendationViewModel.updateViewDuration(
          _viewInteractionId!,
          authViewModel.currentUser!.uid,
          propertyViewModel.property!.id
      );
    }
  }

  Future<void> _toggleFavorite() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final propertyViewModel = Provider.of<PropertyViewModel>(context, listen: false);
    final recommendationViewModel = Provider.of<RecommendationViewModel>(context, listen: false);

    if (!authViewModel.isLoggedIn) {
      // Rediriger vers la page de connexion
      Navigator.pushNamed(context, '/auth');
      return;
    }

    if (propertyViewModel.property == null) return;

    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      if (_isFavorite) {
        await recommendationViewModel.addToFavorites(
            authViewModel.currentUser!.uid,
            propertyViewModel.property!.id
        );
      } else {
        await recommendationViewModel.removeFromFavorites(
            authViewModel.currentUser!.uid,
            propertyViewModel.property!.id
        );
      }
    } catch (e) {
      // En cas d'erreur, revenir à l'état précédent
      setState(() {
        _isFavorite = !_isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<PropertyViewModel, AuthViewModel>(
        builder: (context, propertyViewModel, authViewModel, child) {
          if (propertyViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (propertyViewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    propertyViewModel.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            );
          }

          final property = propertyViewModel.property;

          if (property == null) {
            return const Center(child: Text('Propriété non trouvée'));
          }

          return CustomScrollView(
            slivers: [
              // App bar avec images et boutons d'action
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Carousel d'images
                      FlutterCarousel(
                        items: property.images.map((imageUrl) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            },
                          );
                        }).toList(),
                        options: CarouselOptions(
                          height: 300.0,
                          viewportFraction: 1.0,
                          enlargeCenterPage: false,
                          autoPlay: false,
                          enableInfiniteScroll: property.images.length > 1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                        ),
                      ),

                      // Indicateurs de pagination
                      if (property.images.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: property.images.asMap().entries.map((entry) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(
                                      _currentImageIndex == entry.key ? 1.0 : 0.5
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      // Dégradé pour améliorer la lisibilité des boutons
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black54,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  // Bouton Favoris
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                  // Bouton Partager
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      // Logique de partage
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité de partage à implémenter')),
                      );
                    },
                  ),
                ],
              ),

              // Contenu principal
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre et type
                      Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.type,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Adresse
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${property.location['address']}, ${property.location['city']}, ${property.location['country']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Note et avis
                      if (property.rating > 0)
                        Row(
                          children: [
                            Icon(Icons.star, size: 20, color: Colors.amber[700]),
                            const SizedBox(width: 4),
                            Text(
                              property.rating.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' (${property.reviewCount} avis)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),

                      // Caractéristiques principales
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeature(Icons.people, '${property.capacity} personnes'),
                          _buildFeature(Icons.king_bed, '${property.bedrooms} chambres'),
                          _buildFeature(Icons.bathtub, '${property.bathrooms} SdB'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'À propos de ce logement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Équipements
                      const Text(
                        'Équipements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAmenitiesList(property.amenities),
                      const SizedBox(height: 24),

                      // Informations spéciales Coupe du Monde
                      if (property.worldCupInfo != null)
                        _buildWorldCupInfo(property.worldCupInfo!),

                      const SizedBox(height: 24),

                      // Prix et bouton de réservation
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${property.price.toStringAsFixed(0)}€ / nuit',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Hors taxes et frais',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Naviguer vers la page de réservation
                                Navigator.pushNamed(
                                  context,
                                  '/booking',
                                  arguments: {'propertyId': property.id},
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                'Réserver',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Section des propriétés similaires
              SliverToBoxAdapter(
                child: authViewModel.isLoggedIn
                    ? Consumer<RecommendationViewModel>(
                  builder: (context, recommendationViewModel, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Propriétés similaires',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (recommendationViewModel.isLoadingSimilar)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (recommendationViewModel.similarProperties.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'Aucune propriété similaire disponible',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 280,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recommendationViewModel.similarProperties.length,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemBuilder: (context, index) {
                                final similarProperty = recommendationViewModel.similarProperties[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: _buildPropertyCard(
                                    similarProperty,
                                    authViewModel.currentUser!.uid,
                                    recommendationViewModel,
                                  ),
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 32),
                      ],
                    );
                  },
                )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAmenitiesList(List<String> amenities) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenities.map((amenity) {
        IconData icon;

        // Attribuer une icône en fonction de l'équipement
        switch (amenity.toLowerCase()) {
          case 'wifi':
            icon = Icons.wifi;
            break;
          case 'climatisation':
          case 'air conditioning':
            icon = Icons.ac_unit;
            break;
          case 'parking':
            icon = Icons.local_parking;
            break;
          case 'piscine':
          case 'pool':
            icon = Icons.pool;
            break;
          case 'tv':
          case 'télévision':
            icon = Icons.tv;
            break;
          case 'cuisine':
          case 'kitchen':
            icon = Icons.kitchen;
            break;
          case 'lave-linge':
          case 'washing machine':
            icon = Icons.local_laundry_service;
            break;
          case 'balcon':
          case 'balcony':
            icon = Icons.balcony;
            break;
          default:
            icon = Icons.check_circle;
        }

        return Chip(
          avatar: Icon(icon, size: 16),
          label: Text(amenity),
          backgroundColor: Colors.grey[100],
        );
      }).toList(),
    );
  }

  Widget _buildWorldCupInfo(Map<String, dynamic> worldCupInfo) {
    // Distance du stade
    String? distanceText;
    if (worldCupInfo.containsKey('stadiumDistanceKm')) {
      final distance = worldCupInfo['stadiumDistanceKm'];
      if (distance is num) {
        distanceText = '${distance.toStringAsFixed(1)} km du stade';
      }
    }

    // Nom du stade le plus proche
    final nearbyStadium = worldCupInfo['nearbyStadium'] as String?;

    // Vérifier s'il y a des informations à afficher
    if (distanceText == null && nearbyStadium == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sports_soccer,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Information Coupe du Monde 2030',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (nearbyStadium != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.stadium, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Stade le plus proche: $nearbyStadium',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          if (distanceText != null)
            Row(
              children: [
                const Icon(Icons.directions_walk, size: 18),
                const SizedBox(width: 8),
                Text(
                  distanceText,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(
      Property property,
      String userId,
      RecommendationViewModel recommendationViewModel
      ) {
    return GestureDetector(
      onTap: () {
        // Enregistrer l'interaction de clic
        recommendationViewModel.trackPropertyClick(
            userId,
            property.id,
            {'source': 'similar_property'}
        );

        // Naviguer vers la page de détails
        Navigator.pushReplacementNamed(
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
            // Image
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
                if (property.worldCupInfo != null &&
                    property.worldCupInfo!['worldCupSpecial'] == true)
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
                      child: const Text(
                        'Offre Coupe du Monde',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Informations
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

                  const SizedBox(height: 8),

                  // Capacité
                  Text(
                    '${property.bedrooms} chambres · ${property.capacity} personnes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
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