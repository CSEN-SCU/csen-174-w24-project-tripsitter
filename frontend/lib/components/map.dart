import 'package:flutter/material.dart';

import 'package:mapbox_gl/mapbox_gl.dart';
class TripsitterMap extends StatelessWidget {
  const TripsitterMap({super.key});

  @override
  Widget build(BuildContext context) {
    const String mapboxToken = String.fromEnvironment("MAPBOX_ACCESS_TOKEN");
    return MapboxMap(
      styleString: "mapbox://styles/mapbox/light-v11",
      accessToken: mapboxToken, 
      initialCameraPosition: CameraPosition(target: LatLng(0.0, 0.0), zoom: 1),
    );
  }
}