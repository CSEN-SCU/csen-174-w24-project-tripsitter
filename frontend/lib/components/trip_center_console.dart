import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tripsitter/components/trip_console_dot.dart';

class TripCenterConsole extends StatefulWidget {
  final double maxHeight, maxWidth;
  const TripCenterConsole(this.maxWidth, this.maxHeight, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<TripCenterConsole>
    with TickerProviderStateMixin {
  // state variables go here
  late Map<String, XYPairSized> positions;
  late Map<String, AnimationController> _iconAnimationControllers;
  late Map<String, Animation<double>> _iconAnimations;

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
  late Map<String, double> defaultAngles;

  late double radius;
  late double centerX;
  late double centerY;

  @override
  void initState() {
    super.initState();

    radius = widget.maxHeight * radiusMultiplier;
    centerX = widget.maxWidth * 0.5;
    centerY = widget.maxHeight * 0.1;

    positions = {
      "Hotel": XYPairSized(0.0, 0.0 * 0.1, defaultDotSize),
      "Rental Car": XYPairSized(0.0, 0.0, defaultDotSize),
      "Flights": XYPairSized(0.0, 0.0, defaultDotSize),
      "Activities": XYPairSized(0.0, 0.0, defaultDotSize),
      "City": XYPairSized(
          widget.maxWidth * 0.5, widget.maxHeight * 0.4, defaultDotSize),
    };

    defaultAngles = {
      "Activities": 90 - (1.5 * angleGap),
      "Hotel": 90 - (0.5 * angleGap),
      "Flights": 90 + (0.5 * angleGap),
      "Rental Car": 90 + (1.5 * angleGap),
    };

    _iconAnimationControllers = {
      "Hotel": AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
      "Rental Car": AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
      "Flights": AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
      "Activities": AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    };
    // You can use different Curves for different animation effects
    _iconAnimations = {
      "Hotel": Tween<double>(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(
          parent: _iconAnimationControllers["Hotel"]!,
          curve: Curves.linear,
        ),
      ),
      "Rental Car": Tween<double>(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(
          parent: _iconAnimationControllers["Rental Car"]!,
          curve: Curves.linear,
        ),
      ),
      "Flights": Tween<double>(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(
          parent: _iconAnimationControllers["Flights"]!,
          curve: Curves.linear,
        ),
      ),
      "Activities": Tween<double>(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(
          parent: _iconAnimationControllers["Activities"]!,
          curve: Curves.linear,
        ),
      ),
    };

    // Optionally, you can add listeners or other configurations her
    setElementAngleDegrees(defaultAngles["Activities"]!, "Activities");
    setElementAngleDegrees(defaultAngles["Hotel"]!, "Hotel");
    setElementAngleDegrees(defaultAngles["Flights"]!, "Flights");
    setElementAngleDegrees(defaultAngles["Rental Car"]!, "Rental Car");
  }

  void updateDotX(double newX, String dotName) {
    setState(() {
      positions[dotName]!.setX(newX);
    });
  }

  // Method to update the Y coordinate of the "Hotel" position
  void updateDotY(double newY, String dotName) {
    setState(() {
      positions[dotName]!.setY(newY);
    });
  }

  void updateDotSize(double newSize, String dotName) {
    setState(() {
      positions[dotName]!.setSize(newSize);
    });
  }

  void setElementAngleDegrees(double inputAngle, String dotName) {
    double angle = inputAngle % 360;

    updateDotY(centerY + radius * sin(angle * (pi / 180)), dotName);
    updateDotX(centerX + radius * cos(angle * (pi / 180)), dotName);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TripConsoleDot(
          "Hotel",
          positions,
          _iconAnimationControllers,
          _iconAnimations,
          defaultAngles,
          radius,
          centerX,
          centerY,
          setElementAngleDegrees,
          updateDotSize,
          updateDotX,
          updateDotY,
        ),
        // Hotel
        // AnimatedPositioned(
        //   duration: const Duration(milliseconds: 200),
        //   curve: Curves.linear,
        //   left: positions["Hotel"]!.x - (0.5 * positions["Hotel"]!.size),
        //   top: positions["Hotel"]!.y - (0.5 * positions["Hotel"]!.size),
        //   child: AnimatedContainer(
        //     duration: const Duration(milliseconds: 200),
        //     width: positions["Hotel"]!.size,
        //     height: positions["Hotel"]!.size,
        //     decoration: const BoxDecoration(
        //       shape: BoxShape.circle,
        //       color: Color.fromARGB(255, 0, 0, 0),
        //     ),
        //     child: MouseRegion(
        //       onEnter: (_) {
        //         setElementAngleDegrees(defaultAngles["Hotel"]!, "Hotel");
        //         updateDotSize(defaultDotSize * expandDotFactor, "Hotel");
        //         setElementAngleDegrees(
        //             defaultAngles["Flights"]! + angleGap * gapExpansionFactor,
        //             "Flights");
        //         setElementAngleDegrees(
        //             defaultAngles["Rental Car"]! +
        //                 angleGap * gapExpansionFactor,
        //             "Rental Car");
        //         setElementAngleDegrees(
        //             defaultAngles["Activities"]! -
        //                 angleGap * gapExpansionFactor,
        //             "Activities");

        //         // Start the animation
        //         _iconAnimationControllers["Hotel"]?.forward();
        //       },
        //       onExit: (_) {
        //         setElementAngleDegrees(defaultAngles["Hotel"]!, "Hotel");
        //         updateDotSize(defaultDotSize, "Hotel");
        //         setElementAngleDegrees(defaultAngles["Flights"]!, "Flights");
        //         setElementAngleDegrees(
        //             defaultAngles["Rental Car"]!, "Rental Car");
        //         setElementAngleDegrees(
        //             defaultAngles["Activities"]!, "Activities");
        //         _iconAnimationControllers["Hotel"]?.reverse();
        //       },
        //       child: AnimatedBuilder(
        //         animation: _iconAnimationControllers["Hotel"]!,
        //         builder: (context, child) {
        //           return Icon(
        //             Icons.hotel,
        //             color: Colors.white,
        //             size: _iconAnimations["Hotel"]!.value *
        //                 defaultDotSize *
        //                 iconSizeFactor,
        //           );
        //         },
        //       ),
        //     ),
        //   ),
        // ),
        // Rental Car
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
          left: positions["Rental Car"]!.x -
              (0.5 * positions["Rental Car"]!.size),
          top: positions["Rental Car"]!.y -
              (0.5 * positions["Rental Car"]!.size),
          child: AnimatedContainer(
            alignment: Alignment.center,
            duration: const Duration(milliseconds: 200),
            width: positions["Rental Car"]!.size,
            height: positions["Rental Car"]!.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            child: MouseRegion(
              onEnter: (_) {
                setElementAngleDegrees(
                    defaultAngles["Hotel"]! - angleGap * gapExpansionFactor,
                    "Hotel");
                updateDotSize(defaultDotSize * expandDotFactor, "Rental Car");
                setElementAngleDegrees(
                    defaultAngles["Flights"]! - angleGap * gapExpansionFactor,
                    "Flights");
                setElementAngleDegrees(
                    defaultAngles["Rental Car"]!, "Rental Car");
                setElementAngleDegrees(
                    defaultAngles["Activities"]! -
                        angleGap * gapExpansionFactor,
                    "Activities");
                // Start the animation
                _iconAnimationControllers["Rental Car"]?.forward();
              },
              onExit: (_) {
                setElementAngleDegrees(defaultAngles["Hotel"]!, "Hotel");
                updateDotSize(defaultDotSize, "Rental Car");
                setElementAngleDegrees(defaultAngles["Flights"]!, "Flights");
                setElementAngleDegrees(
                    defaultAngles["Rental Car"]!, "Rental Car");
                setElementAngleDegrees(
                    defaultAngles["Activities"]!, "Activities");

                _iconAnimationControllers["Rental Car"]?.reverse();
              },
              child: AnimatedBuilder(
                animation: _iconAnimationControllers["Rental Car"]!,
                builder: (context, child) {
                  return Icon(
                    Icons.car_rental_outlined,
                    color: Colors.white,
                    size: _iconAnimations["Rental Car"]!.value *
                        defaultDotSize *
                        iconSizeFactor,
                  );
                },
              ),
            ),
          ),
        ),
        // Flights
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
          left: positions["Flights"]!.x - (0.5 * positions["Flights"]!.size),
          top: positions["Flights"]!.y - (0.5 * positions["Flights"]!.size),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: positions["Flights"]!.size,
            height: positions["Flights"]!.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            child: MouseRegion(
              onEnter: (_) {
                setElementAngleDegrees(
                    defaultAngles["Hotel"]! - angleGap * gapExpansionFactor,
                    "Hotel");
                updateDotSize(defaultDotSize * expandDotFactor, "Flights");
                setElementAngleDegrees(defaultAngles["Flights"]!, "Flights");
                setElementAngleDegrees(
                    defaultAngles["Rental Car"]! +
                        angleGap * gapExpansionFactor,
                    "Rental Car");
                setElementAngleDegrees(
                    defaultAngles["Activities"]! -
                        angleGap * gapExpansionFactor,
                    "Activities");
                // Start the animation
                _iconAnimationControllers["Flights"]!.forward();
              },
              onExit: (_) {
                setElementAngleDegrees(defaultAngles["Hotel"]!, "Hotel");
                updateDotSize(defaultDotSize, "Flights");
                setElementAngleDegrees(defaultAngles["Flights"]!, "Flights");
                setElementAngleDegrees(
                    defaultAngles["Rental Car"]!, "Rental Car");
                setElementAngleDegrees(
                    defaultAngles["Activities"]!, "Activities");
                _iconAnimationControllers["Flights"]!.reverse();
              },
              child: AnimatedBuilder(
                animation: _iconAnimationControllers["Flights"]!,
                builder: (context, child) {
                  return Icon(
                    Icons.flight_takeoff_rounded,
                    color: Colors.white,
                    size: _iconAnimations["Flights"]!.value *
                        defaultDotSize *
                        iconSizeFactor,
                  );
                },
              ),
            ),
          ),
        ),
        // Activities
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
          left: positions["Activities"]!.x -
              (0.5 * positions["Activities"]!.size),
          top: positions["Activities"]!.y -
              (0.5 * positions["Activities"]!.size),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: positions["Activities"]!.size,
            height: positions["Activities"]!.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            child: MouseRegion(
              onEnter: (_) {
                setElementAngleDegrees(
                    defaultAngles["Hotel"]! + angleGap * gapExpansionFactor,
                    "Hotel");
                updateDotSize(defaultDotSize * expandDotFactor, "Activities");
                setElementAngleDegrees(
                    defaultAngles["Flights"]! + angleGap * gapExpansionFactor,
                    "Flights");
                setElementAngleDegrees(
                    defaultAngles["Rental Car"]! +
                        angleGap * gapExpansionFactor,
                    "Rental Car");
                setElementAngleDegrees(
                    defaultAngles["Activities"]!, "Activities");

                // Start the animation
                _iconAnimationControllers["Activities"]!.forward();
              },
              onExit: (_) {
                setElementAngleDegrees(defaultAngles["Hotel"]!, "Hotel");
                updateDotSize(defaultDotSize, "Activities");
                setElementAngleDegrees(defaultAngles["Flights"]!, "Flights");
                setElementAngleDegrees(
                    defaultAngles["Rental Car"]!, "Rental Car");
                setElementAngleDegrees(
                    defaultAngles["Activities"]!, "Activities");
                _iconAnimationControllers["Activities"]!.reverse();
              },
              child: AnimatedBuilder(
                animation: _iconAnimationControllers["Activities"]!,
                builder: (context, child) {
                  return Icon(
                    Icons.stadium,
                    color: Colors.white,
                    size: _iconAnimations["Activities"]!.value *
                        defaultDotSize *
                        iconSizeFactor,
                  );
                },
              ),
            ),
          ),
        ),
        // City
        AnimatedPositioned(
          duration: const Duration(microseconds: 200),
          left: positions["City"]!.x - (0.5 * positions["City"]!.size),
          top: positions["City"]!.y - (0.5 * positions["City"]!.size),
          child: Container(
            width: positions["City"]!.size,
            height: positions["City"]!.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 153, 17, 17),
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