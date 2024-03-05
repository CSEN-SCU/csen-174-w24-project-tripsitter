import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:url_launcher/url_launcher.dart';

class TripsitterMap extends StatelessWidget {
  const TripsitterMap({super.key});

  @override
  Widget build(BuildContext context) {
    const String mapboxToken = String.fromEnvironment("MAPBOX_ACCESS_TOKEN");

    return Container(
      height: 520,
      child: MapboxMap(
          initialCameraPosition: CameraPosition(target: LatLng(39.0, -127.0))),
    );
  }
}
