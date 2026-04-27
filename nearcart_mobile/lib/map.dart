import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearcart_mobile/store.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? userLocation;

  final List<Store> stores = [
    Store(name: "OK First Street", lat: -17.828956, lng: 31.049408),
    Store(name: "OK Marimba", lat: -17.829242, lng: 31.009340),
    Store(name: "OK Julius Nyerere", lat: -17.834781, lng: 31.046399),
    Store(name: "OK Queensdale", lat: -17.855017, lng: 31.087227),
    Store(name: "OK Kwame Nkrumah", lat: -17.828443, lng: 31.046016),
    Store(name: "OK Third Street", lat: -17.831181, lng: 31.053624),
    Store(name: "OK Mbare", lat: -17.857751, lng: 31.041248),
    Store(name: "OK Mufakose", lat: -17.864280, lng: 30.930093),
    Store(name: "OK Glen Norah", lat: -17.910748, lng: 30.973726),
    Store(name: "OK Avondale", lat: -17.774289, lng: 31.012121),
    Store(name: "OK Waterfalls", lat: -17.891528, lng: 31.022078),
    Store(name: "OK Machipisa", lat: -17.892108, lng: 30.990745),
    Store(name: "OK Sanganai", lat: -17.791914, lng: 30.955434),
    Store(name: "OK Houghton Park", lat: -17.881014, lng: 31.016924),
    Store(name: "OK St Marys", lat: -17.995203, lng: 31.045036),
  ];

  List<Store> nearestStores = [];

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are ON
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    userLocation = LatLng(position.latitude, position.longitude);

    calculateNearest();

    setState(() {});
  }

  // Future<void> getUserLocation() async {
  //   LocationPermission permission = await Geolocator.requestPermission();
  //
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //
  //   userLocation = LatLng(position.latitude, position.longitude);
  //
  //   calculateNearest();
  //
  //   setState(() {});
  // }

  void calculateNearest() {
    final Distance distance = Distance();

    stores.sort((a, b) {
      double distA = distance(
        userLocation!,
        LatLng(a.lat, a.lng),
      );

      double distB = distance(
        userLocation!,
        LatLng(b.lat, b.lng),
      );

      return distA.compareTo(distB);
    });

    nearestStores = stores.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (userLocation == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: userLocation!,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.nearcart.app',
              ),

              MarkerLayer(
                markers: [
                  // User marker
                  Marker(
                    point: userLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.person_pin_circle,
                        color: Colors.blue, size: 40),
                  ),

                  // Store markers
                  ...stores.map((store) => Marker(
                    point: LatLng(store.lat, store.lng),
                    width: 60,
                    height: 60,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                        Flexible(
                          child: Text(
                            store.name,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  )
                ],
              ),
            ],
          ),

          // Bottom UI (Modern look)
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.15,
            maxChildSize: 0.5,
            builder: (_, controller) {
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: ListView(
                  controller: controller,
                  children: [
                    Text(
                      "Nearest Stores",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),

                    ...nearestStores.map((store) => ListTile(
                      leading: Icon(Icons.store),
                      title: Text(store.name),
                    ))
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}