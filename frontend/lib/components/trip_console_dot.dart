import "dart:math";

import "package:flutter/material.dart";
import "package:tripsitter/components/trip_center_console.dart";

class TripConsoleDot extends StatefulWidget {
  final String name;

  late Map<String, XYPairSized> positions;
  late Map<String, AnimationController> _iconAnimationControllers;
  late Map<String, Animation<double>> _iconAnimations;
  late Map<String, double> defaultAngles;

  late double centerY;
  late double centerX;
  late double radius;

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
    this.name,
    this.positions,
    this._iconAnimationControllers,
    this._iconAnimations,
    this.defaultAngles,
    this.radius,
    this.centerX,
    this.centerY,
    this.setElementAngleDegrees,
    this.updateDotSize,
    this.updateDotX,
    this.updateDotY,
  );

  @override
  _TripConsoleDotState createState() => _TripConsoleDotState();
}

class _TripConsoleDotState extends State<TripConsoleDot> {
  Widget popupPage(String name) {
    return Container(
      color: Colors.red,
      width: 100,
      height: 100,
    );
  }

  void openPopup(myContext, name) {
    showDialog(
      context: myContext,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              color: Colors.grey,
            ),
            child: Stack(children: [
              const Positioned(
                top: 10.0,
                right: 10.0,
                child: CloseButton(),
              ),
              popupPage(widget.name),
            ]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
      left: widget.positions["Hotel"]!.x -
          (0.5 * widget.positions["Hotel"]!.size),
      top: widget.positions["Hotel"]!.y -
          (0.5 * widget.positions["Hotel"]!.size),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.positions["Hotel"]!.size,
        height: widget.positions["Hotel"]!.size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        child: MouseRegion(
          onEnter: (_) {
            widget.setElementAngleDegrees(
                widget.defaultAngles["Hotel"]!, "Hotel");
            widget.updateDotSize(
                widget.defaultDotSize * widget.expandDotFactor, "Hotel");
            widget.setElementAngleDegrees(
                widget.defaultAngles["Flights"]! +
                    widget.angleGap * widget.gapExpansionFactor,
                "Flights");
            widget.setElementAngleDegrees(
                widget.defaultAngles["Rental Car"]! +
                    widget.angleGap * widget.gapExpansionFactor,
                "Rental Car");
            widget.setElementAngleDegrees(
                widget.defaultAngles["Activities"]! -
                    widget.angleGap * widget.gapExpansionFactor,
                "Activities");

            // Start the animation
            widget._iconAnimationControllers["Hotel"]?.forward();
          },
          onExit: (_) {
            widget.setElementAngleDegrees(
                widget.defaultAngles["Hotel"]!, "Hotel");
            widget.updateDotSize(widget.defaultDotSize, "Hotel");
            widget.setElementAngleDegrees(
                widget.defaultAngles["Flights"]!, "Flights");
            widget.setElementAngleDegrees(
                widget.defaultAngles["Rental Car"]!, "Rental Car");
            widget.setElementAngleDegrees(
                widget.defaultAngles["Activities"]!, "Activities");
            widget._iconAnimationControllers["Hotel"]?.reverse();
          },
          child: GestureDetector(
            onTap: () {
              openPopup(context, widget.name);
            },
            child: AnimatedBuilder(
              animation: widget._iconAnimationControllers["Hotel"]!,
              builder: (context, child) {
                return Icon(
                  Icons.hotel,
                  color: Colors.white,
                  size: widget._iconAnimations["Hotel"]!.value *
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
