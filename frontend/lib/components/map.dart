import 'package:flutter/material.dart';

import 'package:mapbox_gl/mapbox_gl.dart';

class TripsitterMap extends StatelessWidget {
  const TripsitterMap({super.key});
  late MapboxMapController mapController;
  List<Marker> markers = [];

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    // Call a function to load markers
    loadMarkers();
  }

  void loadMarkers() {
    // Load markers into the markers list
    markers.add(
      Marker(
        markerId: MarkerId('marker1'),
        position: LatLng(51.5, -0.09), // Marker position
      ),
    );

    // Update the map with the new markers
    mapController.addMarkers(markers);
  }

  @override
  Widget build(BuildContext context) {
    const String mapboxToken = String.fromEnvironment("MAPBOX_ACCESS_TOKEN");
    return MapboxMap(
      styleString: "mapbox://styles/mapbox/light-v11",
      accessToken: mapboxToken,
      initialCameraPosition: CameraPosition(target: LatLng(0.0, 0.0), zoom: 13),
      markers: {},
    );
  }
}
