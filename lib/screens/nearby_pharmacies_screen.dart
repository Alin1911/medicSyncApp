import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class NearbyPharmaciesScreen extends StatefulWidget {
  @override
  _NearbyPharmaciesScreenState createState() => _NearbyPharmaciesScreenState();
}

class _NearbyPharmaciesScreenState extends State<NearbyPharmaciesScreen> {
  GoogleMapController? mapController;
  LatLng? currentPosition;
  Set<Marker> pharmacyMarkers = {};
  Set<Polyline> routePolylines = {};
  Map<String, Map<String, dynamic>> pharmacyDetailsById = {};

  bool openNowOnly = false;
  double minRating = 0.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition();
    currentPosition = LatLng(position.latitude, position.longitude);
    setState(() {});
    _moveCameraToPosition(currentPosition!);
    _searchNearbyPharmacies();
  }

  void _moveCameraToPosition(LatLng position) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15.2),
      ),
    );
  }

  Future<void> _searchNearbyPharmacies() async {
    final apiKey = "AIzaSyBBJH-tZ18IP-mXmcdB8u0iLVKph4ZVlFo";
    if (apiKey == null || currentPosition == null) return;

    String baseUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${currentPosition!.latitude},${currentPosition!.longitude}&radius=3000&type=pharmacy&key=$apiKey';
    if (openNowOnly) {
      baseUrl += '&opennow=true';
    }

    final response = await http.get(Uri.parse(baseUrl));
    final data = json.decode(response.body);

    if (data['results'] != null) {
      Set<Marker> markers = {};
      pharmacyDetailsById.clear();

      for (var pharmacy in data['results']) {
        final rating = (pharmacy['rating'] ?? 0).toDouble();
        if (rating < minRating) continue;

        final lat = pharmacy['geometry']['location']['lat'];
        final lng = pharmacy['geometry']['location']['lng'];
        final name = pharmacy['name'];
        final markerId = MarkerId(name);

        pharmacyDetailsById[name] = pharmacy;

        markers.add(
          Marker(
            markerId: markerId,
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(title: name),
            onTap: () {
              _showPharmacyDetails(pharmacyDetailsById[name]!);
            },
          ),
        );
      }

      setState(() {
        pharmacyMarkers = markers;
        routePolylines.clear(); // clear old route if any
      });
    }
  }

  void _showPharmacyDetails(Map<String, dynamic> pharmacy) async {
    final name = pharmacy['name'] ?? 'Farmacie';
    final rating = (pharmacy['rating'] ?? '-').toString();
    final openNow = pharmacy['opening_hours']?['open_now'] == true;

    final result = await _getDirectionsTo(pharmacy);
    if (result == null) return;
    final distance = result['distance'];
    final duration = result['duration'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Row(
              children: [
                Icon(Icons.local_pharmacy, color: Color(0xff30cfd0), size: 34),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Color(0xff330867),
                    ),
                  ),
                ),
                Chip(
                  label: Text(openNow ? "Deschis" : "Închis"),
                  backgroundColor: openNow ? Colors.green[50] : Colors.red[50],
                  labelStyle: TextStyle(
                    color: openNow ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star, size: 20, color: Colors.amber[600]),
                SizedBox(width: 4),
                Text(rating, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                SizedBox(width: 14),
                Icon(Icons.access_time, size: 20, color: Color(0xff30cfd0)),
                SizedBox(width: 4),
                Text('Durată: $duration', style: TextStyle(fontSize: 15)),
                SizedBox(width: 12),
                Icon(Icons.map_rounded, size: 20, color: Color(0xff30cfd0)),
                SizedBox(width: 4),
                Text('Dist: $distance', style: TextStyle(fontSize: 15)),
              ],
            ),
            if (pharmacy['vicinity'] != null) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.deepPurple[300], size: 22),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pharmacy['vicinity'],
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  )
                ],
              ),
            ],
            SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.directions),
                label: Text("Desenează ruta pe hartă"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff30cfd0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _drawRoute(result['polyline']);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _getDirectionsTo(Map<String, dynamic> pharmacy) async {
    final apiKey = "AIzaSyBBJH-tZ18IP-mXmcdB8u0iLVKph4ZVlFo";
    if (apiKey == null || currentPosition == null) return null;

    final destLat = pharmacy['geometry']['location']['lat'];
    final destLng = pharmacy['geometry']['location']['lng'];

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${currentPosition!.latitude},${currentPosition!.longitude}&destination=$destLat,$destLng&key=$apiKey'
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['routes'].isNotEmpty) {
      final route = data['routes'][0];
      final overviewPolyline = route['overview_polyline']['points'];
      final distance = route['legs'][0]['distance']['text'];
      final duration = route['legs'][0]['duration']['text'];

      return {
        'polyline': overviewPolyline,
        'distance': distance,
        'duration': duration,
      };
    }

    return null;
  }

  void _drawRoute(String encodedPolyline) {
    final points = _decodePolyline(encodedPolyline);
    setState(() {
      routePolylines = {
        Polyline(
          polylineId: PolylineId('route'),
          color: Color(0xff30cfd0),
          width: 5,
          points: points,
        )
      };
    });
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  void _openFilterScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(
          openNow: openNowOnly,
          minRating: minRating,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        openNowOnly = result['openNow'];
        minRating = result['minRating'];
      });
      _searchNearbyPharmacies();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Înălțime status bar și padding safe (pentru plasare butoane sus)
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Stack(
        children: [
          // Harta jos pe tot ecranul
          currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
              _moveCameraToPosition(currentPosition!);
            },
            initialCameraPosition: CameraPosition(
              target: currentPosition!,
              zoom: 15.2,
            ),
            markers: {
              Marker(
                markerId: MarkerId("current_location"),
                position: currentPosition!,
                infoWindow: InfoWindow(title: "Locația ta"),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              ),
              ...pharmacyMarkers,
            },
            polylines: routePolylines,
          ),
          // HEADER MODERN, MIC, TRANSPARENT, PESTE HARTĂ, DOAR SUS
          Positioned(
            top: top + 10, // Safe zone!
            left: 16,
            right: 72, // Lasă loc pt. butonul de filtre
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.local_pharmacy_rounded, color: Color(0xff30cfd0), size: 24),
                  const SizedBox(width: 9),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Farmacii din apropiere",
                        style: TextStyle(
                          color: Color(0xff330867),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Filtrează sau apasă pe marker",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // BUTON FILTRU ROTUND, MIC, DREAPTA SUS
          if (currentPosition != null)
            Positioned(
              top: top + 14,
              right: 16,
              child: ClipOval(
                child: Material(
                  color: Color(0xff30cfd0),
                  child: InkWell(
                    onTap: _openFilterScreen,
                    child: SizedBox(
                      width: 46,
                      height: 46,
                      child: Icon(Icons.filter_alt_rounded, color: Colors.white, size: 26),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: currentPosition == null
          ? null
          : FloatingActionButton(
        heroTag: "myLocBtn",
        backgroundColor: Color(0xff330867),
        onPressed: () => _moveCameraToPosition(currentPosition!),
        child: Icon(Icons.my_location, color: Colors.white),
        tooltip: 'Centrează pe locația ta',
      ),
    );
  }
}

class FilterScreen extends StatefulWidget {
  final bool openNow;
  final double minRating;

  FilterScreen({required this.openNow, required this.minRating});

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late bool openNow;
  late double minRating;

  @override
  void initState() {
    super.initState();
    openNow = widget.openNow;
    minRating = widget.minRating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30cfd0),
        title: Text('Filtre farmacii', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color(0xFFF6F8FB),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text("Doar farmacii deschise acum"),
              value: openNow,
              onChanged: (val) => setState(() => openNow = val),
              activeColor: Color(0xff30cfd0),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Rating minim:", style: TextStyle(fontWeight: FontWeight.w500)),
                Text("${minRating.toStringAsFixed(1)}", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: minRating,
              min: 0,
              max: 5,
              divisions: 10,
              label: minRating.toStringAsFixed(1),
              activeColor: Color(0xff30cfd0),
              onChanged: (val) => setState(() => minRating = val),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.check_circle, color: Colors.white),
                label: Text("Aplică filtrele"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff330867),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'openNow': openNow,
                    'minRating': minRating,
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
