// lib/widgets/recommendations_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/property.dart';
import '../viewmodel/recommendation_viewmodel.dart';
import 'property_card.dart';

// Définition de l'énumération RecommendationType
enum RecommendationType {
  personalized,
  similar,
  worldCup,
  popular
}

class RecommendationsSection extends StatefulWidget {
  final String userId;
  final String title;
  final String emptyMessage;
  final RecommendationType type;
  final String? currentPropertyId;

  const RecommendationsSection({
    Key? key,
    required this.userId,
    required this.title,
    required this.type,
    this.emptyMessage = 'Aucune recommandation disponible',
    this.currentPropertyId,
  }) : super(key: key);

  @override
  _RecommendationsSectionState createState() => _RecommendationsSectionState();
}

class _RecommendationsSectionState extends State<RecommendationsSection> {
  // Code de la classe d'état
  // (ajoutez le reste du code du widget ici)

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          // Ajoutez ici le code pour afficher la liste des propriétés
        ],
      ),
    );
  }
}