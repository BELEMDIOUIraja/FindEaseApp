import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/room_model.dart';
import '../providers/room_provider.dart';
import 'filtre.dart';
import 'booking_screen.dart';
import 'favorites_screen.dart';
import 'bottom_nav_bar.dart';
import '../data/room_data.dart';
import 'filtre.dart';
import 'booking_screen.dart';
import 'bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userFirstName;
  List<Room> filteredRooms = [];
  TextEditingController searchController = TextEditingController();
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);

    // Charge les données depuis room_data.dart
    if (roomProvider.rooms.isEmpty) {
      roomProvider.setRooms(getInitialRooms());
    }

    filteredRooms = roomProvider.rooms;
    searchController.addListener(_filterRooms);
  }
  Future<void> fetchUserFirstName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          userFirstName = doc.data()?['firstName'] ?? 'Bienvenue !';
        });
      }
    }
  }
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterRooms() {
    String query = searchController.text.toLowerCase();
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    setState(() {
      filteredRooms = roomProvider.rooms.where((room) {
        return room.title.toLowerCase().contains(query) ||
            room.location.toLowerCase().contains(query) ||
            room.category.toLowerCase().contains(query);
      }).toList();
    });
  }

  void filterByCategory(String category) {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    setState(() {
      selectedCategory = category;
      if (category.isEmpty) {
        filteredRooms = roomProvider.rooms;
      } else {
        filteredRooms = roomProvider.rooms.where((room) => room.category == category).toList();
      }
    });
  }

  void applyFilters(Map<String, String> filters) {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    setState(() {
      filteredRooms = roomProvider.rooms.where((room) {
        bool matchesPrice = true;

        if (filters['Price']!.isNotEmpty) {
          List<String> priceRange = filters['Price']!.split('-');
          if (priceRange.length == 2) {
            double minPrice = double.parse(priceRange[0]);
            double maxPrice = double.parse(priceRange[1]);
            double roomPrice = double.parse(room.price.replaceAll(' €/nuit', '').replaceAll(',', '.'));
            matchesPrice = roomPrice >= minPrice && roomPrice <= maxPrice;
          }
        }

        return (filters['Category']!.isEmpty || room.category.toLowerCase().contains(filters['Category']!.toLowerCase())) &&
            (filters['Location']!.isEmpty || room.location.toLowerCase().contains(filters['Location']!.toLowerCase())) &&
            (filters['Style']!.isEmpty || room.style.toLowerCase().contains(filters['Style']!.toLowerCase())) &&
            (filters['Interest']!.isEmpty || room.interest.toLowerCase().contains(filters['Interest']!.toLowerCase())) &&
            matchesPrice;
      }).toList();
    });
  }

  void resetFilters() {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    setState(() {
      filteredRooms = roomProvider.rooms;
      selectedCategory = '';
    });
  }
  void fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userFirstName = doc['firstName']; // ou 'lastName' selon ce que tu veux
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final List<Map<String, dynamic>> categories = [
      {'name': 'Maison', 'icon': Icons.home_outlined},
      {'name': 'Villa', 'icon': Icons.villa_outlined},
      {'name': 'Riad', 'icon': Icons.house_siding_outlined},
      {'name': 'Montagne', 'icon': Icons.landscape_outlined},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F0D9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('image/user.jpg'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      userFirstName ?? 'Bienvenue !',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritesScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () async {
                      final filters = await Navigator.push<Map<String, String>>(
                        context,
                        MaterialPageRoute(builder: (context) => const FilterScreen()),
                      );
                      if (filters != null) {
                        applyFilters(filters);
                      }
                    },
                  ),
                  const Icon(Icons.notifications),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Rechercher une ville, un hébergement...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / categories.length;
                  return SizedBox(
                    height: 90,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: categories.map((category) {
                        return SizedBox(
                          width: itemWidth,
                          child: _buildCategoryFilter(
                            category['name'],
                            category['icon'],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filteredRooms.length,
                itemBuilder: (context, index) {
                  final room = filteredRooms[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: RoomCardWithCarousel(
                      room: room,
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(context: context, currentIndex: 0),
    );
  }

  Widget _buildCategoryFilter(String category, IconData icon) {
    bool isSelected = selectedCategory == category;
    return InkWell(
      onTap: () => filterByCategory(isSelected ? '' : category),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.orange : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.orange : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class RoomCardWithCarousel extends StatefulWidget {
  final Room room;
  final VoidCallback onTap;

  const RoomCardWithCarousel({
    super.key,
    required this.room,
    required this.onTap,
  });

  @override
  State<RoomCardWithCarousel> createState() => _RoomCardWithCarouselState();
}

class _RoomCardWithCarouselState extends State<RoomCardWithCarousel> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: widget.room.imagePaths.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.asset(
                        widget.room.imagePaths[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.image_not_supported)),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(
                      widget.room.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: widget.room.isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      roomProvider.toggleFavorite(widget.room.title);
                      setState(() {});
                    },
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.room.imagePaths.length,
                          (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == index
                              ? Colors.orange
                              : Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.room.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.room.title.split(',').first,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.room.description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(widget.room.distance),
                      const Spacer(),
                      Text(widget.room.dates),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.room.price,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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