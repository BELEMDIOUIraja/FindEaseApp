import 'package:flutter/material.dart';
import '../model/room_model.dart';

class RoomProvider with ChangeNotifier {
  List<Room> _rooms = [];

  List<Room> get rooms => _rooms;

  void setRooms(List<Room> rooms) {
    _rooms = rooms;
    notifyListeners();
  }

  void toggleFavorite(String roomTitle) {
    final index = _rooms.indexWhere((room) => room.title == roomTitle);
    if (index != -1) {
      _rooms[index].isFavorite = !_rooms[index].isFavorite;
      notifyListeners();
    }
  }

  void setUserRating(String roomTitle, int rating) {
    final index = _rooms.indexWhere((room) => room.title == roomTitle);
    if (index != -1) {
      _rooms[index].userRating = rating;
      notifyListeners();
    }
  }

  List<Room> get favoriteRooms => _rooms.where((room) => room.isFavorite).toList();
}