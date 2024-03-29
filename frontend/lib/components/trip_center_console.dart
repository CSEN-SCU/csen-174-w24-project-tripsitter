import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/map.dart';
import 'package:tripsitter/components/trip_console_dot.dart';
import 'package:tripsitter/helpers/api.dart';

class TripCenterConsole extends StatefulWidget {
  final Trip trip;
  final double maxHeight, maxWidth;
  const TripCenterConsole(this.trip, this.maxWidth, this.maxHeight, {super.key});

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
  final double angleGap = 30.0;
  // The fraction of the angleGap that the angle is changed by
  final double gapExpansionFactor = 0.3;
  // Multiplier on maxHeight to determine the radius of the circular path
  final double radiusMultiplier = 0.58;
  // default size in pixels of the dots
  final double defaultDotSize = 100.0;
  // factor by which the dots will expand when hovered
  final double expandDotFactor = 1.5;
  // factor of the dot size that the icon inside should be
  final double iconSizeFactor = 0.6;
  late Map<String, double> defaultAngles;

  double get radius => (min(widget.maxHeight, widget.maxWidth)) * radiusMultiplier;
  double get centerX => (widget.maxWidth - min(widget.maxHeight, widget.maxWidth))/2 + min(widget.maxHeight, widget.maxWidth) * 0.5;
  double get centerY => (widget.maxHeight - min(widget.maxHeight, widget.maxWidth))/2 + min(widget.maxHeight, widget.maxWidth) * 0.1;

  double prevMaxWidth = 0;
  double prevMaxHeight = 0;

  String currentPopupState = "None";

  @override
  void initState() {
    super.initState();
    setup();
    TripsitterApi.getCityImage(widget.trip.destination).then((value) {
      if(!mounted) return;
      setState(() {
        cityImage = value;
      });
    });
  }

  String? cityImage;

  void setup() {
    positions = {
      "Hotels": XYPairSized(0.0, 0.0 * 0.1, defaultDotSize),
      "Rental Cars": XYPairSized(0.0, 0.0, defaultDotSize),
      "Flights": XYPairSized(0.0, 0.0, defaultDotSize),
      "Activities": XYPairSized(0.0, 0.0, defaultDotSize),
      "Restaurants": XYPairSized(0.0, 0.0, defaultDotSize),
      "City": XYPairSized(
          (widget.maxWidth - min(widget.maxHeight, widget.maxWidth))/2 + min(widget.maxHeight, widget.maxWidth) * 0.5, 
          (widget.maxHeight - min(widget.maxHeight, widget.maxWidth))/2 + min(widget.maxHeight, widget.maxWidth) * 0.4, defaultDotSize*2),
    };

    defaultAngles = {
      "Activities": 90 - (1.5 * angleGap),
      "Hotels": 90 - (0.75 * angleGap),
      "Restaurants": 90 ,
      "Flights": 90 + (0.75 * angleGap),
      "Rental Cars": 90 + (1.5 * angleGap),
    };

    _iconAnimationControllers = {
      "Hotels": AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
      "Rental Cars": AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
      "Flights": AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
      "Restaurants": AnimationController(
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
      "Hotels": Tween<double>(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(
          parent: _iconAnimationControllers["Hotels"]!,
          curve: Curves.linear,
        ),
      ),
      "Rental Cars": Tween<double>(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(
          parent: _iconAnimationControllers["Rental Cars"]!,
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
      "Restaurants": Tween<double>(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(
          parent: _iconAnimationControllers["Restaurants"]!,
          curve: Curves.linear,
        ),
      ),
    };

    setElementAngleDegrees(defaultAngles["Activities"]!, "Activities");
    setElementAngleDegrees(defaultAngles["Hotels"]!, "Hotels");
    setElementAngleDegrees(defaultAngles["Flights"]!, "Flights");
    setElementAngleDegrees(defaultAngles["Rental Cars"]!, "Rental Cars");
    setElementAngleDegrees(defaultAngles["Restaurants"]!, "Restaurants");

    prevMaxHeight = widget.maxHeight;
    prevMaxWidth = widget.maxWidth;
  }

  void updateDotX(double newX, String dotName) {
    setState(() {
      positions[dotName]!.setX(newX);
    });
  }

  // Method to update the Y coordinate of the "Hotels" position
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

  bool isHovering = false;
  bool get showImage => cityImage !=null && !isHovering;

  Widget transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(showImage) != widget?.key);
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;
        final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: (Matrix4.rotationY(value)..setEntry(3, 0, tilt)),
          child: widget,
          alignment: Alignment.center,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (prevMaxHeight != widget.maxHeight || prevMaxWidth != widget.maxWidth) {
      setup();
    }
    return Center(
      child: Stack(
        children: [
          TripConsoleDot(
              trip: widget.trip,
              type: PageType.hotel,
              positions: positions,
              iconAnimationControllers: _iconAnimationControllers,
              iconAnimations: _iconAnimations,
              onEnter: (_) {
                setElementAngleDegrees(defaultAngles["Hotels"]!, "Hotels");
                updateDotSize(defaultDotSize * expandDotFactor, "Hotels");
                setElementAngleDegrees(
                    defaultAngles["Flights"]! + angleGap * gapExpansionFactor,
                    "Flights");
                setElementAngleDegrees(
                    defaultAngles["Rental Cars"]! +
                        angleGap * gapExpansionFactor,
                    "Rental Cars");
                setElementAngleDegrees(
                    defaultAngles["Activities"]! -
                        angleGap * gapExpansionFactor,
                    "Activities");
                setElementAngleDegrees(
                    defaultAngles["Restaurants"]! + angleGap * gapExpansionFactor,
                    "Restaurants");
      
                // Start the animation
                _iconAnimationControllers["Hotels"]?.forward();
              },
              onExit: (_) {
                setElementAngleDegrees(defaultAngles["Hotels"]!, "Hotels");
                updateDotSize(defaultDotSize, "Hotels");
                setElementAngleDegrees(defaultAngles["Flights"]!, "Flights");
                setElementAngleDegrees(defaultAngles["Restaurants"]!, "Restaurants");
                setElementAngleDegrees(
                    defaultAngles["Rental Cars"]!, "Rental Cars");
                setElementAngleDegrees(
                    defaultAngles["Activities"]!, "Activities");
                _iconAnimationControllers["Hotels"]?.reverse();
              },
          ),
          // Rental Cars
          TripConsoleDot(
              trip: widget.trip,
            type: PageType.rentalCar, 
            positions: positions, 
            iconAnimationControllers: _iconAnimationControllers, 
            iconAnimations: _iconAnimations, 
            onEnter: (_) {
                  setElementAngleDegrees(
                      defaultAngles["Hotels"]! - angleGap * gapExpansionFactor,
                      "Hotels");
                  updateDotSize(defaultDotSize * expandDotFactor, "Rental Cars");
                  setElementAngleDegrees(
                      defaultAngles["Flights"]! - angleGap * gapExpansionFactor,
                      "Flights");
                  setElementAngleDegrees(
                      defaultAngles["Rental Cars"]!, "Rental Cars");
                  setElementAngleDegrees(
                      defaultAngles["Activities"]! -
                          angleGap * gapExpansionFactor,
                      "Activities");
                  setElementAngleDegrees(
                      defaultAngles["Restaurants"]! -
                          angleGap * gapExpansionFactor,
                      "Restaurants");
                  // Start the animation
                  _iconAnimationControllers["Rental Cars"]?.forward();
                },
                onExit: (_) {
                  setElementAngleDegrees(defaultAngles["Hotels"]!, "Hotels");
                  updateDotSize(defaultDotSize, "Rental Cars");
                  setElementAngleDegrees(defaultAngles["Flights"]!, "Flights");
                  setElementAngleDegrees(defaultAngles["Restaurants"]!, "Restaurants");
                  setElementAngleDegrees(
                      defaultAngles["Rental Cars"]!, "Rental Cars");
                  setElementAngleDegrees(
                      defaultAngles["Activities"]!, "Activities");
      
                  _iconAnimationControllers["Rental Cars"]?.reverse();
                },
          ),
          // Flights
          TripConsoleDot(
              trip: widget.trip,
            type: PageType.flights, 
            positions: positions, 
            iconAnimationControllers: _iconAnimationControllers, 
            iconAnimations: _iconAnimations, 
            onEnter: (_) {
              setElementAngleDegrees(
                  defaultAngles["Hotels"]! - angleGap * gapExpansionFactor,
                  "Hotels");
              updateDotSize(defaultDotSize * expandDotFactor, "Flights");
              setElementAngleDegrees(defaultAngles["Flights"]!, "Flights");
              setElementAngleDegrees(
                  defaultAngles["Rental Cars"]! +
                      angleGap * gapExpansionFactor,
                  "Rental Cars");
              setElementAngleDegrees(
                  defaultAngles["Activities"]! -
                      angleGap * gapExpansionFactor,
                  "Activities");
              setElementAngleDegrees(
                  defaultAngles["Restaurants"]! -
                      angleGap * gapExpansionFactor,
                  "Restaurants");
              // Start the animation
              _iconAnimationControllers["Flights"]!.forward();
            },
            onExit: (_) {
              setElementAngleDegrees(defaultAngles["Hotels"]!, "Hotels");
              updateDotSize(defaultDotSize, "Flights");
              setElementAngleDegrees(defaultAngles["Flights"]!, "Flights");
              setElementAngleDegrees(defaultAngles["Restaurants"]!, "Restaurants");
              setElementAngleDegrees(
                  defaultAngles["Rental Cars"]!, "Rental Cars");
              setElementAngleDegrees(
                  defaultAngles["Activities"]!, "Activities");
              _iconAnimationControllers["Flights"]!.reverse();
            },
          ),
          // Restaurants
          TripConsoleDot(
              trip: widget.trip,
            type: PageType.restaurants, 
            positions: positions, 
            iconAnimationControllers: _iconAnimationControllers, 
            iconAnimations: _iconAnimations, 
            onEnter: (_) {
              setElementAngleDegrees(
                  defaultAngles["Hotels"]! - angleGap * gapExpansionFactor,
                  "Hotels");
              updateDotSize(defaultDotSize * expandDotFactor, "Restaurants");
              setElementAngleDegrees(defaultAngles["Restaurants"]!, "Restaurants");
              setElementAngleDegrees(
                  defaultAngles["Rental Cars"]! +
                      angleGap * gapExpansionFactor,
                  "Rental Cars");
              setElementAngleDegrees(
                  defaultAngles["Flights"]! +
                      angleGap * gapExpansionFactor,
                  "Flights");
              setElementAngleDegrees(
                  defaultAngles["Activities"]! -
                      angleGap * gapExpansionFactor,
                  "Activities");
              // Start the animation
              _iconAnimationControllers["Restaurants"]!.forward();
            },
            onExit: (_) {
              setElementAngleDegrees(defaultAngles["Hotels"]!, "Hotels");
              updateDotSize(defaultDotSize, "Restaurants");
              setElementAngleDegrees(defaultAngles["Restaurants"]!, "Restaurants");
              setElementAngleDegrees(defaultAngles["Flights"]!, "Flights");
              setElementAngleDegrees(
                  defaultAngles["Rental Cars"]!, "Rental Cars");
              setElementAngleDegrees(
                  defaultAngles["Activities"]!, "Activities");
              _iconAnimationControllers["Restaurants"]!.reverse();
            },
          ),
          // Activities
          TripConsoleDot(
            trip: widget.trip,
            type: PageType.activities, 
            positions: positions, 
            iconAnimationControllers: _iconAnimationControllers, 
            iconAnimations: _iconAnimations, 
            onEnter: (_) {
                  setElementAngleDegrees(
                      defaultAngles["Hotels"]! + angleGap * gapExpansionFactor,
                      "Hotels");
                  updateDotSize(defaultDotSize * expandDotFactor, "Activities");
                  setElementAngleDegrees(
                      defaultAngles["Flights"]! + angleGap * gapExpansionFactor,
                      "Flights");
                  setElementAngleDegrees(
                      defaultAngles["Restaurants"]! + angleGap * gapExpansionFactor,
                      "Restaurants");
                  setElementAngleDegrees(
                      defaultAngles["Rental Cars"]! +
                          angleGap * gapExpansionFactor,
                      "Rental Cars");
                  setElementAngleDegrees(
                      defaultAngles["Activities"]!, "Activities");
      
                  // Start the animation
                  _iconAnimationControllers["Activities"]!.forward();
                },
                onExit: (_) {
                  setElementAngleDegrees(defaultAngles["Hotels"]!, "Hotels");
                  updateDotSize(defaultDotSize, "Activities");
                  setElementAngleDegrees(defaultAngles["Flights"]!, "Flights");
                setElementAngleDegrees(defaultAngles["Restaurants"]!, "Restaurants");
                  setElementAngleDegrees(
                      defaultAngles["Rental Cars"]!, "Rental Cars");
                  setElementAngleDegrees(
                      defaultAngles["Activities"]!, "Activities");
                  _iconAnimationControllers["Activities"]!.reverse();
                },
          ),
          // City
          AnimatedPositioned(
            duration: const Duration(microseconds: 200),
            left: positions["City"]!.x - (0.5 * positions["City"]!.size),
            top: positions["City"]!.y - (0.5 * positions["City"]!.size),
            child: SizedBox(
              width: positions["City"]!.size,
              height: positions["City"]!.size,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) {
                  setState(() {
                    isHovering = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isHovering = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
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
                              TripsitterMap<int>(
                                items: List<int>.empty(),
                                createWidget: (r) {
                                  return Container();
                                },
                                trip: widget.trip, 
                                getLat: (r) => 0.0, 
                                getLon: (r) => 0.0, 
                                isSelected: (r) => false, 
                                extras: const [
                                  MarkerType.activity,
                                  MarkerType.hotel,
                                  MarkerType.restaurant,
                                  MarkerType.airport,
                                ]
                              ),
                              const Positioned(
                                top: 10.0,
                                right: 10.0,
                                child: TsCloseButton(),
                              ),
                            ]),
                          ),
                        );
                      },
                    );
                  },
                  child: AnimatedSwitcher(
                    transitionBuilder: transitionBuilder,
                    layoutBuilder: (widget, list) => Stack(children: [if(widget != null) widget, ...list]),
                    switchInCurve: Curves.easeInBack,
                    switchOutCurve: Curves.easeInBack.flipped,
                    duration: Duration(milliseconds: 350),
                    child: showImage ? CircleAvatar(
                      radius: 0.5 * positions["City"]!.size,
                      key: ValueKey(true),
                      backgroundImage: MemoryImage(base64Decode(cityImage!.split("data:image/jpeg;base64,")[1]))
                    ) : Container(
                    key: ValueKey(false),
                      width: positions["City"]!.size,
                      height: positions["City"]!.size,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 153, 17, 17),
                      ),
                      child: Icon(
                        Icons.pin_drop,
                        color: Colors.white,
                        size: positions["City"]!.size * 0.7,
                      ),
                    ),
                  ),
                ),
              )
            ),
          ),
        ],
      ),
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
