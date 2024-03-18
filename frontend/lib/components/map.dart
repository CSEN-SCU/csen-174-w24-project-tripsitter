import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:tripsitter/classes/airport.dart';
import 'package:tripsitter/classes/hotels.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/classes/yelp.dart';
import 'package:tripsitter/helpers/locators.dart';
import 'package:tripsitter/helpers/data.dart';

class TripsitterMap<T> extends StatefulWidget {
  final List<T> items;
  final Trip trip;
  final List<MarkerType> extras;

  final double Function(T item) getLat;
  final double Function(T item) getLon;
  final bool Function(T item) isSelected;
  final bool Function(T item)? isOption;
  final bool Function(T item)? isOther;
  final Widget Function(T item) createWidget;
  const TripsitterMap({required this.items, required this.createWidget, required this.trip, required this.getLat, required this.getLon, required this.isSelected, required this.extras, this.isOption, this.isOther, super.key});

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
      if(widget.items.isEmpty) return;
      widget.items.forEachIndexed((i, item) {
        var point = Point<double>(value[i].x as double, value[i].y as double);
        var eventDistance = distance(
          widget.trip.destination.lat,
          widget.trip.destination.lon,
          params[i].latitude,
          params[i].longitude,
        );
        addMarker(point, params[i], isSelected: widget.isSelected(item), isOption: widget.isOption?.call(item) ?? false, isOther: widget.isOther?.call(item) ?? false, popupWidget: widget.createWidget(item));
        markersCount++;
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
              type: MarkerType.hotel,
              item: element.selectedInfo
          );
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
                  LatLng(airport.lat, airport.lon), type: MarkerType.airport, item: airport);
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
              type: MarkerType.restaurant, item: meal.restaurant);
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
                type: MarkerType.activity, item: activity.event);
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
      if(_markerStates.isEmpty) return;
      _markerStates.asMap().forEach((i, value) {
        if(_markerStates.length <= i || points.length <= i) return;
        _markerStates[i].updatePosition(points[i]);
      });
    });
  }

  void addMarker(
    Point<double> point,
    LatLng coordinates,
    {
      MarkerType type = MarkerType.item,
      Widget? popupWidget,
      dynamic item,
      bool isSelected = false,
      bool isOption = false,
      bool isOther = false,
    }
  ) {
    setState(() {
      _markers.add(
        Marker(
          coordinate: coordinates,
          initialPosition: point,
          addMarkerState: addMarkerStates,
          isSelected: isSelected,
          isOther: isOther,
          isOption: isOption,
          popupWidget: popupWidget,
          item: item,
          type: type
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void _onCameraIdleCallback() {
    _updateMarkerPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            MapboxMap(
              styleString: isLight ? MapboxStyles.LIGHT : MapboxStyles.DARK,
              trackCameraPosition: true,
              accessToken: mapboxApiKey,
              onMapCreated: _onMapCreated,
              onCameraIdle: _onCameraIdleCallback,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    widget.trip.destination.lat, widget.trip.destination.lon),
                zoom: 10.0,
              ),
            ),
            ..._markers,
          ],
        ),
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
  final bool isSelected, isOther, isOption;
  final Widget? popupWidget;
  final dynamic? item;

  Marker({
    required this.coordinate,
    required this.initialPosition,
    required this.addMarkerState,
    required this.isSelected,
    required this.isOther,
    required this.isOption,
    this.type = MarkerType.item,
    this.item,
    this.popupWidget,
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

  bool showPopup = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  Icon getIcon() {
    switch (type) {
      case MarkerType.item:
        return Icon(Icons.location_on, color: widget.isSelected ? Colors.blue : (widget.isOption ? Colors.green : (widget.isOther ? Colors.redAccent : Colors.black)), size: _iconSize);
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

  Widget summaryWidget() {
    if(widget.item is HotelInfo) {
      HotelInfo hotel = widget.item as HotelInfo;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hotel.name, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      );
    } else if(widget.item is TicketmasterEvent) {
      TicketmasterEvent event = widget.item as TicketmasterEvent;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(event.venues.firstOrNull?.name ??""),
          Text("(Starts ${event.startTime.localDate} ${event.startTime.localTime})")
        ],
      );
    } else if(widget.item is YelpRestaurant) {
      YelpRestaurant restaurant = widget.item as YelpRestaurant;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(restaurant.name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text("${restaurant.price ?? ""}\n★ ${restaurant.rating.toString()}")
        ],
      );
    } else if(widget.item is Airport) {
      Airport airport = widget.item as Airport;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(airport.name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(airport.iataCode),
        ],
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    var ratio = 1.0;

    //web does not support Platform._operatingSystem
    if (!kIsWeb) {
      // iOS returns logical pixel while Android returns screen pixel
      ratio = Platform.isIOS ? 1.0 : MediaQuery.of(context).devicePixelRatio;
    }
    Icon icon = getIcon();
    return Positioned(
      left: _position.x / ratio - (type == MarkerType.item ? _iconSize : _iconSize * 1.5) / 2,
      top: _position.y / ratio - (type == MarkerType.item ? _iconSize : _iconSize * 1.5) / 2,
      child: PopupMenuButton(
        tooltip: "View",
        itemBuilder: (BuildContext context) { 
          return <PopupMenuEntry>[
            PopupMenuItem(
              value: 'view',
              child: (type == MarkerType.item && widget.popupWidget != null) ? widget.popupWidget : Padding(
                padding: const EdgeInsets.all(8.0),
                child: summaryWidget(),
              ),
            ),
          ];
         },
        child: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(child: icon))
      ),
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
