import 'dart:html';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:url_launcher/url_launcher.dart';

class TripsitterMap extends StatefulWidget {
  final List<TicketmasterEvent>? events;
  final Trip trip;
  const TripsitterMap({this.events, required this.trip, super.key});

  @override
  State createState() => TripsitterMapState();
}

class TripsitterMapState extends State<TripsitterMap> {
  final String mapboxApiKey =
      const String.fromEnvironment("MAPBOX_ACCESS_TOKEN");
  MapboxMapController? mapController;
  var isLight = true;
  int markersCount = 0;

  List<Marker> _markers = [];
  List<_MarkerState> _markerStates = [];

  void _addMarkerStates(_MarkerState markerState) {
    _markerStates.add(markerState);
  }

  _onMapCreated(MapboxMapController controller) {
    markersCount = 0;
    mapController = controller;

    var params = <LatLng>[];

    widget.events?.forEach((event) {
      double lat = event.venues[0].latitude ?? 0.0;
      double lng = event.venues[0].longitude ?? 0.0;
      params.add(LatLng(lat, lng));
    });

    controller.toScreenLocationBatch(params).then((value) {
      widget.events?.forEachIndexed((i, event) {
        var point = Point<double>(value[i].x as double, value[i].y as double);
        _addMarker(point, params[i]);
        markersCount++;
      });
    });
    print(widget.trip.hotels);
    if (widget.trip.hotels.isNotEmpty) {
      print(widget.trip.hotels.first.selectedInfo);
      controller
          .toScreenLocation(LatLng(
              widget.trip.hotels.first.selectedInfo?.latitude ?? 0.0,
              widget.trip.hotels.first.selectedInfo?.longitude ?? 0.0))
          .then((value) {
        _addHotelMarker(
            Point<double>(value.x as double, value.y as double),
            LatLng(widget.trip.hotels.first.selectedInfo?.latitude ?? 0.0,
                widget.trip.hotels.first.selectedInfo?.longitude ?? 0.0));
      });
    }
    controller.addListener(() {
      if (controller.isCameraMoving) {
        _updateMarkerPosition();
      }
    });
  }

  void _onStyleLoadedCallback() {
    print('onStyleLoadedCallback');
  }

  void _updateMarkerPosition() {
    final coordinates = <LatLng>[];

    for (final markerState in _markerStates) {
      coordinates.add(markerState.getCoordinate());
    }

    mapController?.toScreenLocationBatch(coordinates).then((points) {
      _markerStates.asMap().forEach((i, value) {
        _markerStates[i].updatePosition(points[i]);
      });
    });
  }

  void _addMarker(
    Point<double> point,
    LatLng coordinates,
  ) {
    setState(() {
      _markers.add(
        Marker(
            coordinate: coordinates,
            initialPosition: point,
            addMarkerState: _addMarkerStates,
            isHotel: false),
      );
    });
  }

  void _addHotelMarker(Point<double> point, LatLng coordinates) {
    setState(() {
      _markers.add(
        Marker(
            coordinate: coordinates,
            initialPosition: point,
            addMarkerState: _addMarkerStates,
            isHotel: true),
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapboxMap(
            styleString: isLight ? MapboxStyles.LIGHT : MapboxStyles.DARK,
            accessToken: mapboxApiKey,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  widget.trip.destination.lat, widget.trip.destination.lon),
              zoom: 10.0,
            ),
          ),
          ..._markers,
        ],
      ),
    );
  }
}

class Marker extends StatefulWidget {
  final Point initialPosition;
  final LatLng coordinate;
  final void Function(_MarkerState) addMarkerState;
  bool isHotel = false;

  Marker({
    required this.coordinate,
    required this.initialPosition,
    required this.addMarkerState,
    required this.isHotel,
    super.key,
  });

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    final state = _MarkerState(initialPosition, isHotel);
    addMarkerState(state);
    return state;
  }
}

class _MarkerState extends State with TickerProviderStateMixin {
  final double _iconSize = 30.0;

  Point _position;
  bool isHotel;

  _MarkerState(this._position, this.isHotel);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var ratio = 1.0;

    return Positioned(
        left: _position.x / ratio - (isHotel ? _iconSize * 2 : _iconSize) / 2,
        top: _position.y / ratio - (isHotel ? _iconSize * 2 : _iconSize) / 2,
        child: Icon(Icons.place,
            size: (isHotel ? _iconSize * 2 : _iconSize),
            color: isHotel ? Colors.redAccent : Colors.black));
  }

  void updatePosition(Point<num> point) {
    setState(() {
      _position = point;
    });
  }

  LatLng getCoordinate() {
    return (widget as Marker).coordinate;
  }
}
