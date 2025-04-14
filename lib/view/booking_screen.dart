import 'bottom_nav_bar.dart';
import 'package:flutter/material.dart';
// Remplacer Google Maps par Flutter Map
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/room_model.dart';
import '../providers/room_provider.dart';

class BookingScreen extends StatefulWidget {
  final String title;
  final String description;
  final String price;
  final List<String> imagePaths;

  const BookingScreen({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.imagePaths,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _showPaymentForm = false;
  final List<String> _comments = [
    "Très belle chambre, je recommande !",
    "Propriétaire très sympa, bon emplacement.",
  ];
  final TextEditingController _commentController = TextEditingController();
  int _currentImageIndex = 0;
  bool _hasRated = false;
  bool _isFavorite = false;
  int _userRating = 0;

  // Changer LatLng de Google Maps en LatLng de latlong2
  final LatLng _roomLocation = const LatLng(31.9566, -9.7282);
  // Nous n'avons plus besoin du controller avec Flutter Map
  // late GoogleMapController _mapController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final roomProvider = Provider.of<RoomProvider>(context);
    final room = roomProvider.rooms.firstWhere(
          (r) => r.title == widget.title,
      orElse: () => Room(
        title: widget.title,
        description: widget.description,
        price: widget.price,
        imagePaths: widget.imagePaths,
        distance: '',
        rating: 0,
        dates: '',
        category: '',
        location: '',
        style: '',
        interest: '',
        priceRange: '',
      ),
    );
    _isFavorite = room.isFavorite;
    _userRating = room.userRating;
    _hasRated = room.userRating > 0;
  }

  // Nous n'avons plus besoin de cette méthode avec Flutter Map
  // void _onMapCreated(GoogleMapController controller) {
  //   _mapController = controller;
  // }

  Future<void> _selectDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      TimeOfDay? start = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (start != null) {
        TimeOfDay? end = await showTimePicker(
          context: context,
          initialTime: start,
        );

        if (end != null) {
          setState(() {
            _selectedDate = date;
            _startTime = start;
            _endTime = end;
            _showPaymentForm = true;
          });
        }
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.Hm().format(dt);
  }

  void _previousImage() {
    setState(() {
      _currentImageIndex =
          (_currentImageIndex - 1 + widget.imagePaths.length) % widget.imagePaths.length;
    });
  }

  void _nextImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % widget.imagePaths.length;
    });
  }
  void _rateRoom(int rating) {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    roomProvider.setUserRating(widget.title, rating);
    setState(() {
      _userRating = rating;
      _hasRated = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Merci pour votre note de $rating étoiles !')),
    );
  }

  void _toggleFavorite() {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    roomProvider.toggleFavorite(widget.title);
    setState(() {
      _isFavorite = !_isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Ajouté aux favoris' : 'Retiré des favoris'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du logement"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      widget.imagePaths[_currentImageIndex],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 90,
                  child: GestureDetector(
                    onTap: _previousImage,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black45,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 90,
                  child: GestureDetector(
                    onTap: _nextImage,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black45,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.imagePaths.length,
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
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(widget.description),
            const SizedBox(height: 10),
            Text("Prix: ${widget.price}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: InkWell(
                onTap: _toggleFavorite,
                child: Row(
                  children: [
                    Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                      style: TextStyle(
                        color: _isFavorite ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            !_showPaymentForm
                ? ElevatedButton(
              onPressed: _selectDateTime,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Réserver maintenant"),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Date sélectionnée: ${DateFormat.yMMMMd('fr_FR').format(_selectedDate!)}"),
                Text("Heure de début: ${_formatTime(_startTime!)}"),
                Text("Heure de fin: ${_formatTime(_endTime!)}"),
                const SizedBox(height: 16),
                _buildPaymentForm(),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(),
            const Text("Notez ce logement", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _userRating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 30,
                  ),
                  onPressed: () => _rateRoom(index + 1),
                );
              }),
            ),
            if (_hasRated)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Vous avez donné $_userRating étoiles',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            const Text("Commentaires", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            for (var comment in _comments)
              ListTile(
                leading: const Icon(Icons.comment, color: Colors.orange),
                title: Text(comment),
              ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: "Ajouter un commentaire",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_commentController.text.trim().isNotEmpty) {
                      setState(() {
                        _comments.add(_commentController.text.trim());
                        _commentController.clear();
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text("Localisation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Remplacer GoogleMap par FlutterMap
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  center: _roomLocation,
                  zoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: _roomLocation,
                        builder: (ctx) => const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40.0,
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
      bottomNavigationBar: BottomNavBar(context: context, currentIndex: 1),
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Informations de paiement", style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(decoration: InputDecoration(labelText: "Nom sur la carte")),
        TextField(decoration: InputDecoration(labelText: "Numéro de carte")),
        TextField(decoration: InputDecoration(labelText: "Date d'expiration")),
        TextField(decoration: InputDecoration(labelText: "CVV")),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: null,
          style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.green)),
          child: Text("Payer"),
        ),
      ],
    );
  }
}