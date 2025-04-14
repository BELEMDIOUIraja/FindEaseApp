// lib/view/feedback_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/feedback_viewmodel.dart';

class FeedbackView extends StatelessWidget {
  const FeedbackView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3E9),
      appBar: AppBar(
        title: const Text(
          'Feedback',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        backgroundColor: const Color(0xFFF8F3E9),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: Consumer<FeedbackViewModel>(
        builder: (context, viewModel, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section de feedback textuel
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter your feedback',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.brown,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE67E22),
                            ),
                          ),
                          hintText: 'Tell us about your experience...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          contentPadding: const EdgeInsets.all(15),
                        ),
                        maxLines: 5,
                        onChanged: viewModel.setFeedbackText,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Section de réaction emoji
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'How was your experience?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Ligne d'émojis pour réaction
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildEmojiReaction(context, viewModel, 0, '😠'),
                              _buildEmojiReaction(context, viewModel, 1, '🙁'),
                              _buildEmojiReaction(context, viewModel, 2, '😐'),
                              _buildEmojiReaction(context, viewModel, 3, '🙂'),
                              _buildEmojiReaction(context, viewModel, 4, '😄'),
                            ],
                          ),

                          // Grand emoji qui apparaît au clic
                          if (viewModel.showBigEmoji && viewModel.emojiRating != null)
                            _getBigEmoji(viewModel.emojiRating!),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Bouton d'envoi
                ElevatedButton(
                  onPressed: viewModel.isSubmitting
                      ? null
                      : () async {
                    final success = await viewModel.submitFeedback();
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feedback envoyé avec succès !'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: viewModel.isSubmitting
                      ? const SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Envoyer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

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

                const SizedBox(height: 30),

                // Indicateur de sentiment
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Émoji du sentiment actuel
                        if (viewModel.emojiRating != null)
                          Text(
                            _getEmojiString(viewModel.emojiRating!),
                            style: const TextStyle(fontSize: 20),
                          ),
                        const SizedBox(width: 10),
                        Text(
                          _getSentimentText(viewModel.emojiRating),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _getSentimentColor(viewModel.emojiRating),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
            // Icône Accueil
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/match-housing-offers');
              },
              child: const Icon(Icons.home, color: Colors.grey, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiReaction(
      BuildContext context,
      FeedbackViewModel viewModel,
      int index,
      String emoji,
      ) {
    final bool isSelected = viewModel.emojiRating == index;

    return GestureDetector(
      onTap: () => viewModel.setEmojiRating(index),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE67E22).withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 30),
          ),
        ),
      ),
    );
  }

  Widget _getBigEmoji(int index) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Text(
        _getEmojiString(index),
        style: const TextStyle(fontSize: 120),
      ),
    );
  }

  String _getEmojiString(int index) {
    switch (index) {
      case 0:
        return '😠';
      case 1:
        return '🙁';
      case 2:
        return '😐';
      case 3:
        return '🙂';
      case 4:
        return '😄';
      default:
        return '😐';
    }
  }

  String _getSentimentText(int? rating) {
    if (rating == null) return 'Sélectionnez une émotion';

    switch (rating) {
      case 0:
        return 'Très négatif';
      case 1:
        return 'Négatif';
      case 2:
        return 'Neutre';
      case 3:
        return 'Positif';
      case 4:
        return 'Très positif';
      default:
        return 'Neutre';
    }
  }

  Color _getSentimentColor(int? rating) {
    if (rating == null) return Colors.grey;

    switch (rating) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.green[600]!;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}