import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import "package:tripsitter/classes/profile.dart";
import "package:tripsitter/classes/trip.dart";
import "package:tripsitter/components/select_cars.dart";
import "package:tripsitter/components/select_events.dart";
import "package:tripsitter/components/select_flight.dart";
import "package:tripsitter/components/select_hotel.dart";
import "package:tripsitter/components/trip_center_console.dart";

class TripConsoleDot extends StatefulWidget {
  final String type;
  final Trip trip;

  final Map<String, XYPairSized> positions;
  final Map<String, AnimationController> iconAnimationControllers;
  final Map<String, Animation<double>> iconAnimations;

  final Function(PointerEnterEvent) onEnter;
  final Function(PointerExitEvent) onExit;

  // Configurations go Here
  // The initial gap in degrees between the four dots
  final double angleGap = 25.0;
  // The fraction of the angleGap that the angle is changed by
  final double gapExpansionFactor = 0.4;
  // Multiplier on maxHeight to determine the radius of the circular path
  final double radiusMultiplier = 0.6;
  // default size in pixels of the dots
  final double defaultDotSize = 100.0;
  // factor by which the dots will expand when hovered
  final double expandDotFactor = 1.5;
  // factor of the dot size that the icon inside should be
  final double iconSizeFactor = 0.6;

  late Function setElementAngleDegrees;
  late Function updateDotSize;
  late Function updateDotX;
  late Function updateDotY;

  TripConsoleDot(
    {
      required this.trip,
      required this.type,
      required this.positions,
      required this.iconAnimationControllers,
      required this.iconAnimations,
      required this.onEnter,
      required this.onExit,
    }
  );

  @override
  _TripConsoleDotState createState() => _TripConsoleDotState();
}

class PageType { 
  static const String Hotel = "Hotel";
  static const String Flights = "Flights";
  static const String RentalCar = "Rental Car";
  static const String Activities = "Activities";
  static const String Cities = "Cities";
}

class _TripConsoleDotState extends State<TripConsoleDot> {
  Widget popupPage(String page, List<UserProfile> profiles) {
    switch (page) {
      case PageType.Hotel:
        return const SelectHotel();
      case PageType.Flights:
        return const SelectFlight();
      case PageType.RentalCar:
        return SelectCars(widget.trip, profiles);
      case PageType.Activities:
        return SelectEvents(widget.trip, profiles);
      case PageType.Cities:
        return const Text("Change city");
    }
    return Container();
  }

  void openPopup(myContext) {
    List<UserProfile> profiles = Provider.of<List<UserProfile>>(myContext, listen: false);
    showDialog(
      context: myContext,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              color: Colors.white,
            ),
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: popupPage(widget.type, profiles),
              ),
              const Positioned(
                top: 10.0,
                right: 10.0,
                child: CloseButton(),
              ),
            ]),
          ),
        );
      },
    );
  }

  IconData get icon {
    switch (widget.type) {
      case PageType.Hotel:
        return Icons.hotel;
      case PageType.Flights:
        return Icons.flight_takeoff_rounded;
      case PageType.RentalCar:
        return Icons.directions_car;
      case PageType.Activities:
        return Icons.stadium;
      case PageType.Cities:
        return Icons.location_city;
    }
    return Icons.error;
  }

  String get type {
    return widget.type;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
      left: widget.positions[type]!.x -
          (0.5 * widget.positions[type]!.size),
      top: widget.positions[type]!.y -
          (0.5 * widget.positions[type]!.size),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.positions[type]!.size,
        height: widget.positions[type]!.size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        child: MouseRegion(
          onEnter: widget.onEnter,
          onExit: widget.onExit,
          child: GestureDetector(
            onTap: () {
              openPopup(context);
            },
            child: AnimatedBuilder(
              animation: widget.iconAnimationControllers[type]!,
              builder: (context, child) {
                return Icon(
                  icon,
                  color: Colors.white,
                  size: widget.iconAnimations[type]!.value *
                      widget.defaultDotSize *
                      widget.iconSizeFactor,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CloseButton extends StatelessWidget {
  const CloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: const ButtonStyle(
          iconColor:
              MaterialStatePropertyAll<Color>(Color.fromARGB(255, 95, 95, 95)),
          backgroundColor:
              MaterialStatePropertyAll<Color>(Color.fromARGB(0, 0, 0, 0)),
          shadowColor: MaterialStatePropertyAll(
            Color.fromARGB(0, 1, 1, 1),
          ),
          alignment: Alignment.center,
          padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.zero,
          ),
        ),
        child: const Icon(
          Icons.close,
          size: 50,
        ),
      ),
    );
  }
}
