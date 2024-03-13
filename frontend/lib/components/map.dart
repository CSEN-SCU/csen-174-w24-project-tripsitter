import 'dart:html';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/helpers/locators.dart';
import 'package:tripsitter/helpers/data.dart';

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

  _onMapCreated(MapboxMapController controller) async {
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
        var eventDistance = distance(
          widget.trip.destination.lat,
          widget.trip.destination.lon,
          params[i].latitude,
          params[i].longitude,
        );
        var isNearby = eventDistance < 50.0;
        if (isNearby) {
          _addMarker(point, params[i]);
          markersCount++;
        }
      });
    });
    if (widget.trip.hotels.isNotEmpty) {
      var selectionLists =
          widget.trip.hotels.where((s) => s.selectedInfo != null).toList();
      selectionLists.forEach((element) {
        controller
            .toScreenLocation(LatLng(element.selectedInfo?.latitude ?? 0.0,
                element.selectedInfo?.longitude ?? 0.0))
            .then((value) {
          _addHotelMarker(
              Point<double>(value.x as double, value.y as double),
              LatLng(element.selectedInfo?.latitude ?? 0.0,
                  element.selectedInfo?.longitude ?? 0.0));
        });
      });
    }
    if (widget.trip.flights.isNotEmpty) {
      var airports = await getAirports(context);
      widget.trip.flights.forEach((element) {
        airports.forEach((airport) {
          if (airport.iataCode == element.arrivalAirport) {
            controller
                .toScreenLocation(LatLng(airport.lat, airport.lon))
                .then((value) {
              _addAirportMarker(
                  Point<double>(value.x as double, value.y as double),
                  LatLng(airport.lat, airport.lon));
            });
          }
        });
      });
      // var selectionLists =
      //     widget.trip.flights.where((s) => s.arrivalAirport != null).toList();
      // debugPrint("Selected Hotel Groups:");
      // debugPrint(selectionLists);
      // selectionLists.forEach((element) {
      //   debugPrint(element);
      //   controller
      //       .toScreenLocation(LatLng(element.selectedInfo?.latitude ?? 0.0,
      //           element.selectedInfo?.longitude ?? 0.0))
      //       .then((value) {
      //     debugPrint(element.selectedInfo);
      //     _addHotelMarker(
      //         Point<double>(value.x as double, value.y as double),
      //         LatLng(element.selectedInfo?.latitude ?? 0.0,
      //             element.selectedInfo?.longitude ?? 0.0));
      //   });
      // });
    }

    controller.addListener(() {
      if (controller.isCameraMoving) {
        _updateMarkerPosition();
      }
    });
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
          isHotel: false,
          isAirport: false,
        ),
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
          isHotel: true,
          isAirport: false,
        ),
      );
    });
  }

  void _addAirportMarker(Point<double> point, LatLng coordinates) {
    setState(() {
      _markers.add(
        Marker(
          coordinate: coordinates,
          initialPosition: point,
          addMarkerState: _addMarkerStates,
          isHotel: false,
          isAirport: true,
        ),
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
  bool isAirport = false;

  Marker({
    required this.coordinate,
    required this.initialPosition,
    required this.addMarkerState,
    required this.isHotel,
    required this.isAirport,
    super.key,
  });

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    final state = _MarkerState(initialPosition, isHotel, isAirport);
    addMarkerState(state);
    return state;
  }
}

class _MarkerState extends State with TickerProviderStateMixin {
  final double _iconSize = 30.0;

  Point _position;
  bool isHotel;
  bool isAirport;

  _MarkerState(
    this._position,
    this.isHotel,
    this.isAirport,
  );

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
    var icon = Icon(Icons.place, size: _iconSize, color: Colors.black);
    if (isHotel) {
      icon = Icon(Icons.hotel, size: _iconSize * 2, color: Colors.redAccent);
    } else if (isAirport) {
      icon = Icon(Icons.local_airport,
          size: _iconSize * 2, color: Colors.redAccent);
    }
    return Positioned(
      left: _position.x / ratio - (isHotel ? _iconSize * 2 : _iconSize) / 2,
      top: _position.y / ratio - (isHotel ? _iconSize * 2 : _iconSize) / 2,
      child: icon,
    );
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
