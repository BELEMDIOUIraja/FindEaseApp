// lib/widgets/filter_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/property_viewmodel.dart';
import '../viewmodel/recommendation_viewmodel.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({Key? key}) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _selectedCategory;
  String? _selectedLocation;
  String? _selectedStyle;
  String? _selectedInterest;
  RangeValues _priceRange = const RangeValues(0, 5000);

  // Ces valeurs seraient idéalement chargées dynamiquement
  final List<String> _categories = ['Villa', 'Appartement', 'Maison', 'Chambre d\'hôte'];
  final List<String> _locations = ['Casablanca', 'Rabat', 'Marrakech', 'Tanger', 'Madrid', 'Barcelone', 'Lisbonne'];
  final List<String> _styles = ['Moderne', 'Traditionnel', 'Luxe', 'Économique'];
  final List<String> _interests = ['Près des stades', 'Centre-ville', 'Plage', 'Montagne'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Filtres'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Catégorie
            const Text('Category'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Localisation
            const Text('Location'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                items: _locations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Style
            const Text('Style'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedStyle,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                items: _styles.map((style) {
                  return DropdownMenuItem(
                    value: style,
                    child: Text(style),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStyle = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Intérêt (centré sur la Coupe du Monde)
            const Text('Interest'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedInterest,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                items: _interests.map((interest) {
                  return DropdownMenuItem(
                    value: interest,
                    child: Text(interest),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedInterest = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Fourchette de prix
            const Text('Price range'),
            const SizedBox(height: 16),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 5000,
              divisions: 50,
              labels: RangeLabels(
                '${_priceRange.start.round()} DH',
                '${_priceRange.end.round()} DH',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),

            const SizedBox(height: 24),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Réinitialiser les filtres
                      setState(() {
                        _selectedCategory = null;
                        _selectedLocation = null;
                        _selectedStyle = null;
                        _selectedInterest = null;
                        _priceRange = const RangeValues(0, 5000);
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Appliquer les filtres et les passer au modèle de recommandation
                      final Map<String, dynamic> filters = {
                        if (_selectedCategory != null) 'type': _selectedCategory,
                        if (_selectedLocation != null) 'location': _selectedLocation,
                        if (_selectedStyle != null) 'style': _selectedStyle,
                        if (_selectedInterest != null) 'interest': _selectedInterest,
                        'minPrice': _priceRange.start,
                        'maxPrice': _priceRange.end,
                      };

                      // Mettre à jour les recommandations avec ces filtres
                      final recommendationViewModel = Provider.of<RecommendationViewModel>(context, listen: false);
                      recommendationViewModel.applyFilters(filters);

                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}