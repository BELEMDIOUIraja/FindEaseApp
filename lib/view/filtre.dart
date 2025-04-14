import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // 🔤 Import des traductions
import 'bottom_nav_bar.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController styleController = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void resetFilters() {
    categoryController.clear();
    locationController.clear();
    styleController.clear();
    interestController.clear();
    priceController.clear();
  }

  void applyFilters() {
    Map<String, String> filters = {
      'Category': categoryController.text.trim(),
      'Location': locationController.text.trim(),
      'Style': styleController.text.trim(),
      'Interest': interestController.text.trim(),
      'Price': priceController.text.trim(),
    };
    Navigator.pop(context, filters);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // 💬 Raccourci pour traductions

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(loc.filtersTitle, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilterField(
              loc.categoryLabel,
              categoryController,
              hintText: loc.categoryHint,
            ),
            _buildFilterField(
              loc.locationLabel,
              locationController,
              hintText: loc.locationHint,
            ),
            _buildFilterField(
              loc.styleLabel,
              styleController,
              hintText: loc.styleHint,
            ),
            _buildFilterField(
              loc.interestLabel,
              interestController,
              hintText: loc.interestHint,
            ),
            _buildPriceRangeField(loc),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: resetFilters,
                    child: Text(loc.reset),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: applyFilters,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: Text(loc.apply),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(context: context, currentIndex: 1),
    );
  }

  Widget _buildFilterField(String label, TextEditingController controller, {required String hintText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          filled: true,
          fillColor: const Color(0xFFF9F0D9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildPriceRangeField(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: priceController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
          LengthLimitingTextInputFormatter(7),
        ],
        decoration: InputDecoration(
          labelText: loc.priceLabel,
          hintText: loc.priceHint,
          filled: true,
          fillColor: const Color(0xFFF9F0D9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}