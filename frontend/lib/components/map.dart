import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TripsitterMap extends StatelessWidget {
  TripsitterMap({super.key});

  @override
  Widget build(BuildContext context) {
    const String mapboxToken = String.fromEnvironment("MAPBOX_ACCESS_TOKEN");

    return FlutterMap(
      options: MapOptions(
          initialCenter: LatLng(51.5074, 0.1278),
          initialZoom: 16.0,
          maxZoom: 10.0),
      children: [TileLayer(urlTemplate: 'https://api.mapbox.com/styles/v1/drobotcamo/clsxmrjm6004901pt97s9caep/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxToken',)],
    );
  }
}
