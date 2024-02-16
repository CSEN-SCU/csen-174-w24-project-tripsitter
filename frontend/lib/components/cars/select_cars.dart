import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/car.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/cars/cars_groups.dart';
import 'package:tripsitter/components/cars/cars_options.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/helpers/formatters.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectCars extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;
  const SelectCars(this.trip, this.profiles, {super.key});

  @override
  State<SelectCars> createState() => _SelectCarsState();
}

class _SelectCarsState extends State<SelectCars> {
  RentalCarGroup? currentGroup;

  @override
  Widget build(BuildContext context) {
    bool isMobile = Provider.of<bool>(context);
    if(isMobile) {
      return CarGroups(
        profiles: widget.profiles,
        trip: widget.trip, 
        currentGroup: currentGroup, 
        setCurrentGroup: (RentalCarGroup? group) {
          setState(() {
            currentGroup = group;
          });
        },
        setState: () => setState((){}),
      );
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), bottomLeft: Radius.circular(25.0)),
                  color: Color.fromARGB(255, 200, 200, 200),
                ),
              width: constraints.maxWidth * 0.35,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CarGroups(
                  profiles: widget.profiles,
                  trip: widget.trip, 
                  currentGroup: currentGroup, 
                  setCurrentGroup: (RentalCarGroup? group) {
                    setState(() {
                      currentGroup = group;
                    });
                  },
                  setState: () => setState((){}),
                )
              )
            ),
            Container(
              width: constraints.maxWidth * 0.65,
              child: CarOptions(currentGroup: currentGroup, setState: () => setState((){}))
            ),
          ]
        );
      }
    );
  }
}