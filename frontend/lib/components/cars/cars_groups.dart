import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/car.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/cars/car_info_dialog.dart';
import 'package:tripsitter/components/cars/cars_options.dart';
import 'package:tripsitter/components/mobile_wrapper.dart';
import 'package:tripsitter/helpers/formatters.dart';

class CarGroups extends StatefulWidget {
  final List<UserProfile> profiles;
  final Trip trip;
  final RentalCarGroup? currentGroup;
  final Function setState;
  final Function(RentalCarGroup?) setCurrentGroup;

  const CarGroups({required this.setState, required this.profiles, required this.trip, required this.currentGroup, required this.setCurrentGroup, super.key});

  @override
  State<CarGroups> createState() => _CarGroupsState();
}

class _CarGroupsState extends State<CarGroups> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = Provider.of<bool>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          Text('Selections', style: Theme.of(context).textTheme.displayMedium?.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
          for (RentalCarGroup group in widget.trip.rentalCars)
            Container(
              color: widget.currentGroup == group ? Colors.blue : Colors.transparent,
              child: Column(
                children: [
                  ListTile(
                    title: TextFormField(
                      initialValue: group.name,
                      decoration: InputDecoration(
                        labelText: "Group Name",
                      ),
                      onChanged: (String value) {
                        setState(() {
                          group.setName(value);
                        });
                        widget.setState();
                      },
                    ),
                    subtitle: Text(group.members.map((uid) => widget.profiles.firstWhere((e) => e.id == uid).name).join(", ")),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<UserProfile>(
                          itemBuilder: (BuildContext context) {
                            return widget.profiles.where((profile){
                              for (RentalCarGroup g in widget.trip.rentalCars) {
                                if(g.members.contains(profile.id) && group != g) {
                                  return false;
                                }
                              }
                              return true;
                            }).map((UserProfile profile) => PopupMenuItem(
                              value: profile,
                              child: Row(
                                children: [
                                  group.members.contains(profile.id) ? Icon(Icons.check) : Icon(Icons.add),
                                  Text(profile.name),
                                ],
                              ),
                            )).toList();
                          },
                          child: Icon(Icons.add),
                          onSelected: (UserProfile profile) async {
                            if(group.members.contains(profile.id)) {
                              await group.removeMember(profile.id);
                            } else {
                              await group.addMember(profile.id);
                            }
                            setState(() {});
                            widget.setState();
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              widget.setCurrentGroup(group);
                            });
                            widget.setState();
                          },
                          icon: Icon(Icons.car_rental)
                        ),
                        IconButton(
                          onPressed: () async {
                            await widget.trip.removeRentalCarGroup(group);
                            if(widget.currentGroup == group) {
                              widget.setCurrentGroup(null);
                            }
                            setState(() {});
                            widget.setState();
                          },
                          icon: Icon(Icons.delete)
                        ),
                      ],
                    ),
                  ),
                  ...group.options.map((RentalCarOffer car) => ListTile(
                    title: Text("${car.sipp.fromSipp()} (${car.carName} or similar)"),
                    subtitle: Text("${car.provider.providerName}, \$${car.price.toStringAsFixed(2)}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.info),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CarInfoDialog(car);
                              }
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await group.removeOption(car);
                            setState(() {});
                            widget.setState();
                          },
                        ),
                      ],
                    ),
                  )),
                  if(isMobile)
                    ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(title: "Add Car Options", child: CarOptions(currentGroup: group, setState: () => setState((){}),))));
                      },
                      label: Text("Add Options")
                    ),
                  Divider(),
                ],
              )
            ),
          // check if all profiles are in a group
          if(!(widget.profiles.length > 0 && widget.trip.rentalCars.length > 0 && widget.profiles.every((profile) => widget.trip.rentalCars.any((group) => group.members.contains(profile.id))) && widget.trip.rentalCars.every((group) => group.members.length > 0)))
            ElevatedButton(
              onPressed: () async {
                RentalCarGroup newGroup = await widget.trip.createRentalCarGroup("Group ${widget.trip.rentalCars.length + 1}", List<String>.empty(growable: true));
                if(!isMobile) {
                  widget.setCurrentGroup(newGroup);
                }
                if(mounted) {
                  setState(() {});
                }
              },
              child: Text("Create New Group"),
            ),
        ]
      ),
    );
  }
}