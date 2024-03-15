import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/helpers/locators.dart';
import 'package:tripsitter/helpers/data.dart';

class TripsitterMap<T> extends StatefulWidget {
  final List<T> items;
  final Trip trip;
  final List<MarkerType> extras;

  final double Function(T item) getLat;
  final double Function(T item) getLon;
  final bool Function(T item) isSelected;
  const TripsitterMap({required this.items, required this.trip, required this.getLat, required this.getLon, required this.isSelected, required this.extras, super.key});

  @override
  State createState() => TripsitterMapState();
}

class TripsitterMapState extends State<TripsitterMap> {
  final String mapboxApiKey =
      const String.fromEnvironment("MAPBOX_ACCESS_TOKEN");
  MapboxMapController? mapController;
  var isLight = true;
  int markersCount = 0;

  final List<Marker> _markers = [];
  final List<MarkerState> _markerStates = [];

  void addMarkerStates(MarkerState markerState) {
    _markerStates.add(markerState);
  }

  _onMapCreated(MapboxMapController controller) async {
    markersCount = 0;
    mapController = controller;

    var params = <LatLng>[];

    for (var item in widget.items) {
      double lat = widget.getLat(item);
      double lng = widget.getLon(item);
      params.add(LatLng(lat, lng));
    }

    controller.toScreenLocationBatch(params).then((value) {
      widget.items.forEachIndexed((i, item) {
        var point = Point<double>(value[i].x as double, value[i].y as double);
        var eventDistance = distance(
          widget.trip.destination.lat,
          widget.trip.destination.lon,
          params[i].latitude,
          params[i].longitude,
        );
        var isNearby = eventDistance < 50.0;
        if (isNearby) {
          addMarker(point, params[i], isSelected: widget.isSelected(item));
          markersCount++;
        }
      });
    });
    if (widget.trip.hotels.isNotEmpty && widget.extras.contains(MarkerType.hotel)) {
      var selectionLists =
          widget.trip.hotels.where((s) => s.selectedInfo != null).toList();
      for (var element in selectionLists) {
        controller
            .toScreenLocation(LatLng(element.selectedInfo?.latitude ?? 0.0,
                element.selectedInfo?.longitude ?? 0.0))
            .then((value) {
          addMarker(
              Point<double>(value.x as double, value.y as double),
              LatLng(element.selectedInfo?.latitude ?? 0.0,
                  element.selectedInfo?.longitude ?? 0.0),
              type: MarkerType.hotel);
        });
      }
    }
    if (widget.trip.flights.isNotEmpty && widget.extras.contains(MarkerType.airport)) {
      var airports = await getAirports(context);
      for (var element in widget.trip.flights) {
        for (var airport in airports) {
          if (airport.iataCode == element.arrivalAirport) {
            controller
                .toScreenLocation(LatLng(airport.lat, airport.lon))
                .then((value) {
              addMarker(
                  Point<double>(value.x as double, value.y as double),
                  LatLng(airport.lat, airport.lon), type: MarkerType.airport);
            });
          }
        }
      }
    }
    if (widget.trip.meals.isNotEmpty && widget.extras.contains(MarkerType.restaurant)) {
      for (Meal meal in widget.trip.meals) {
        LatLng latLng = LatLng(meal.restaurant.coordinates.latitude,
                meal.restaurant.coordinates.longitude);
        controller
            .toScreenLocation(latLng)
            .then((value) {
          addMarker(
              Point<double>(value.x as double, value.y as double),
              latLng,
              type: MarkerType.restaurant);
        });
      }
    }

    if (widget.trip.activities.isNotEmpty && widget.extras.contains(MarkerType.activity)) {
      for (Activity activity in widget.trip.activities) {
        for(TicketmasterVenue venue in activity.event.venues) {
            LatLng latLng = LatLng(venue.latitude ?? 0.0,
                  venue.longitude ?? 0.0);
          controller
              .toScreenLocation(latLng)
              .then((value) {
            addMarker(
                Point<double>(value.x as double, value.y as double),
                latLng,
                type: MarkerType.activity);
          });
        }
      }
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

  void addMarker(
    Point<double> point,
    LatLng coordinates,
    {
      MarkerType type = MarkerType.item,
      bool isSelected = false,
    }
  ) {
    setState(() {
      _markers.add(
        Marker(
          coordinate: coordinates,
          initialPosition: point,
          addMarkerState: addMarkerStates,
          isSelected: isSelected,
          type: type
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
    return SizedBox(
      height: 520,
      child: Stack(
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

enum MarkerType {
  item,
  hotel,
  airport,
  restaurant,
  activity
}

class Marker extends StatefulWidget {
  final Point initialPosition;
  final LatLng coordinate;
  final void Function(MarkerState) addMarkerState;
  final MarkerType type;
  final bool isSelected;

  Marker({
    required this.coordinate,
    required this.initialPosition,
    required this.addMarkerState,
    required this.isSelected,
    this.type = MarkerType.item,
    super.key,
  });

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    final state = MarkerState();
    addMarkerState(state);
    return state;
  }
}

class MarkerState extends State<Marker> with TickerProviderStateMixin {
  final double _iconSize = 30.0;

  MarkerType get type => widget.type;
  late Point<num> _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  Icon getIcon() {
    switch (type) {
      case MarkerType.item:
        return Icon(Icons.location_on, color: widget.isSelected ? Colors.blue : Colors.black, size: _iconSize);
      case MarkerType.hotel:
        return Icon(Icons.hotel, color: Colors.redAccent, size: _iconSize * 1.5);
      case MarkerType.airport:
        return Icon(Icons.airplanemode_active, color: Colors.redAccent, size: _iconSize * 1.5);
      case MarkerType.restaurant:
        return Icon(Icons.restaurant, color: Colors.redAccent, size: _iconSize * 1.5);
      case MarkerType.activity:
        return Icon(Icons.local_activity, color: Colors.redAccent, size: _iconSize * 1.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    var ratio = 1.0;
    Icon icon = getIcon();
    return Positioned(
      left: _position.x / ratio - (type == MarkerType.item ? _iconSize : _iconSize * 1.5) / 2,
      top: _position.y / ratio - (type == MarkerType.item ? _iconSize : _iconSize * 1.5) / 2,
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
