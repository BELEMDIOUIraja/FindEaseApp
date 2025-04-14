import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/room_model.dart';
import '../providers/room_provider.dart';
import 'booking_screen.dart';
import 'bottom_nav_bar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteRooms = Provider.of<RoomProvider>(context).favoriteRooms;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        backgroundColor: Colors.orange,
      ),
      body: favoriteRooms.isEmpty
          ? const Center(
        child: Text(
          'Aucun favoris pour le moment',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: favoriteRooms.length,
        itemBuilder: (context, index) {
          final room = favoriteRooms[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Image.asset(
                room.imagePaths.first,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              title: Text(room.title),
              subtitle: Text(room.price),
              trailing: const Icon(Icons.favorite, color: Colors.red),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(
                      title: room.title,
                      description: room.description,
                      price: room.price,
                      imagePaths: room.imagePaths,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(context: context, currentIndex: 0),
    );
  }
}