import 'package:flutter/material.dart';

class TripCenterConsole extends StatefulWidget {
  final double maxHeight, maxWidth;
  const TripCenterConsole(this.maxWidth, this.maxHeight, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<TripCenterConsole> {
  // state variables go here
  late Map<String, XYPairSized> positions;

  @override
  void initState() {
    super.initState();
    positions = {
      "Hotel": XYPairSized(widget.maxWidth * 0.1, widget.maxHeight * 0.1, 80),
      "Rental Car":
          XYPairSized(widget.maxWidth * 0.1, widget.maxHeight * 0.3, 100),
      "Flights":
          XYPairSized(widget.maxWidth * 0.1, widget.maxHeight * 0.5, 100),
      "Activities":
          XYPairSized(widget.maxWidth * 0.5, widget.maxHeight * 0.1, 100),
      "City": XYPairSized(widget.maxWidth * 0.5, widget.maxHeight * 0.5, 100),
    };
  }

  void updateHotelX(double newX) {
    setState(() {
      positions["Hotel"]!.setX(newX);
    });
  }

  // Method to update the Y coordinate of the "Hotel" position
  void updateHotelY(double newY) {
    setState(() {
      positions["Hotel"]!.setY(newY);
    });
  }

  void updateHotelSize(double newSize) {
    setState(() {
      positions["Hotel"]!.setSize(newSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hotel
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          left: positions["Hotel"]!.x,
          top: positions["Hotel"]!.y,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: positions["Hotel"]!.size,
            height: positions["Hotel"]!.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            child: MouseRegion(
              onEnter: (_) {
                updateHotelX(150);
                updateHotelSize(150);
              },
              onExit: (_) {
                updateHotelX(100);
                updateHotelSize(100);
              },
              child: AnimatedBuilder(
                animation: _iconAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _iconAnimation.value,
                    child: Icon(
                      Icons.hotel,
                      color: Colors.white,
                      size: positions["Hotel"]!.size * 0.7,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        // Rental Car
        AnimatedPositioned(
          duration: const Duration(microseconds: 500),
          left: positions["Rental Car"]!.x,
          top: positions["Rental Car"]!.y,
          child: Container(
            width: positions["Rental Car"]!.size,
            height: positions["Rental Car"]!.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            child: Icon(
              Icons.car_rental_rounded,
              color: Colors.white,
              size: positions["Rental Car"]!.size * 0.7,
            ),
          ),
        ),
        // Flights
        AnimatedPositioned(
          duration: const Duration(microseconds: 500),
          left: positions["Flights"]!.x,
          top: positions["Flights"]!.y,
          child: Container(
            width: positions["Flights"]!.size,
            height: positions["Flights"]!.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            child: Icon(
              Icons.flight_takeoff_rounded,
              color: Colors.white,
              size: positions["Flights"]!.size * 0.7,
            ),
          ),
        ),
        // Activities
        AnimatedPositioned(
          duration: const Duration(microseconds: 500),
          left: positions["Activities"]!.x,
          top: positions["Activities"]!.y,
          child: Container(
            width: positions["Activities"]!.size,
            height: positions["Activities"]!.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            child: Icon(
              Icons.stadium,
              color: Colors.white,
              size: positions["Activities"]!.size * 0.7,
            ),
          ),
        ),
        // City
        AnimatedPositioned(
          duration: const Duration(microseconds: 500),
          left: positions["City"]!.x,
          top: positions["City"]!.y,
          child: Container(
            width: positions["City"]!.size,
            height: positions["City"]!.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            child: Icon(
              Icons.location_city,
              color: Colors.white,
              size: positions["City"]!.size * 0.7,
            ),
          ),
        ),
      ],
    );
  }
}

class XYPairSized {
  double x = 0;
  double y = 0;
  double size = 0;

  XYPairSized(this.x, this.y, this.size);

  void setX(double input) {
    x = input;
  }

  void setY(double input) {
    y = input;
  }

  void setSize(double input) {
    size = input;
  }
}
