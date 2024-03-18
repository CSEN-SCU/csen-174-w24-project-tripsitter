import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/car.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/cars/car_info_dialog.dart';
import 'package:tripsitter/components/cars/cars_options.dart';
import 'package:tripsitter/components/comments_popup.dart';
import 'package:tripsitter/components/mobile_wrapper.dart';
import 'package:tripsitter/helpers/formatters.dart';
import 'package:google_fonts/google_fonts.dart';

class CarGroups extends StatefulWidget {
  final List<UserProfile> profiles;
  final Trip trip;
  final RentalCarGroup? currentGroup;
  final Function setState;
  final Function(RentalCarGroup?) setCurrentGroup;

  const CarGroups(
      {required this.setState,
      required this.profiles,
      required this.trip,
      required this.currentGroup,
      required this.setCurrentGroup,
      super.key});

  @override
  State<CarGroups> createState() => _CarGroupsState();
}

class _CarGroupsState extends State<CarGroups> {
  Trip get trip => widget.trip;
  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);
    bool isMobile = Provider.of<bool>(context);
    return Container(
      color: const Color.fromARGB(255, 200, 200, 200),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(children: [
          // Text('Selections', style: Theme.of(context).textTheme.displayMedium?.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
          Center(
            child: Text(
              'Rental Car Groups',
              style: GoogleFonts.kadwa(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
          ),
          for (RentalCarGroup group in widget.trip.rentalCars)
            Column(
              children: [
                Container(
                    decoration: BoxDecoration(
                      color: group == widget.currentGroup
                          ? Colors.blue[200]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: group == widget.currentGroup
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: TextFormField(
                            initialValue: group.name,
                            decoration: const InputDecoration(
                              labelText: "Group Name",
                            ),
                            onChanged: (String value) {
                              setState(() {
                                group.setName(value);
                              });
                              widget.setState();
                            },
                          ),
                          subtitle: Text(group.members
                              .map((uid) => widget.profiles
                                  .firstWhere((e) => e.id == uid)
                                  .name)
                              .join(", ")),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PopupMenuButton<UserProfile>(
                                itemBuilder: (BuildContext context) {
                                  return widget.profiles
                                      .where((profile) {
                                        for (RentalCarGroup g
                                            in widget.trip.rentalCars) {
                                          if (g.members.contains(profile.id) &&
                                              group != g) {
                                            return false;
                                          }
                                        }
                                        return true;
                                      })
                                      .map((UserProfile profile) =>
                                          PopupMenuItem(
                                            value: profile,
                                            child: Row(
                                              children: [
                                                group.members
                                                        .contains(profile.id)
                                                    ? const Icon(Icons.check)
                                                    : const Icon(Icons.add),
                                                Text(profile.name),
                                              ],
                                            ),
                                          ))
                                      .toList();
                                },
                                child: const Icon(Icons.people),
                                onSelected: (UserProfile profile) async {
                                  if (group.members.contains(profile.id)) {
                                    await group.removeMember(profile.id);
                                  } else {
                                    await group.addMember(profile.id);
                                  }
                                  setState(() {});
                                  widget.setState();
                                },
                              ),
                              // IconButton(
                              //     onPressed: () {
                              //       setState(() {
                              //         widget.setCurrentGroup(group);
                              //       });
                              //       widget.setState();
                              //     },
                              //     icon: const Icon(Icons.car_rental)),
                              IconButton(
                                  onPressed: () async {
                                    await widget.trip
                                        .removeRentalCarGroup(group);
                                    if (widget.currentGroup == group) {
                                      widget.setCurrentGroup(null);
                                    }
                                    setState(() {});
                                    widget.setState();
                                  },
                                  icon: const Icon(Icons.delete)),
                            ],
                          ),
                          onTap: isMobile
                              ? null
                              : () {
                                  setState(() {
                                    widget.setCurrentGroup(group);
                                  });
                                  widget.setState();
                                },
                        ),
                        ...group.options.map((RentalCarOffer car) => ListTile(
                              leading: Radio<RentalCarOffer>(
                                value: car,
                                groupValue: group.selected,
                                onChanged: (RentalCarOffer? value) async {
                                  if (value == null) return;
                                  await group.selectOption(value);
                                  setState(() {});
                                  widget.setState();
                                },
                              ),
                              title: Text(
                                  "${car.sipp.fromSipp()} (${car.carName} or similar)"),
                              subtitle: Text(
                                  "${car.provider.providerName}, \$${car.price.toStringAsFixed(2)}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.info),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CarInfoDialog(car);
                                          });
                                    },
                                  ),
                                  CommentsPopup(
                                    comments: car.comments,
                                    profiles: widget.profiles,
                                    myUid: user!.uid,
                                    removeComment: (TripComment comment) async {
                                      car.removeComment(comment);
                                      await trip.save();
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    addComment: (String comment) async {
                                      car.addComment(TripComment(
                                          comment: comment,
                                          uid: user.uid,
                                          date: DateTime.now()));
                                      await trip.save();
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      await group.removeOption(car);
                                      setState(() {});
                                      widget.setState();
                                    },
                                  ),
                                ],
                              ),
                              onTap: isMobile
                                  ? null
                                  : () {
                                      setState(() {
                                        widget.setCurrentGroup(group);
                                      });
                                      widget.setState();
                                    },
                            )),
                        if (isMobile)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MobileWrapper(
                                              title: "Add Car Options",
                                              child: CarOptions(
                                                currentGroup: group,
                                                setState: () => setState(() {}),
                                              ))));
                                },
                                label: const Text("Add Options")),
                          ),
                      ],
                    )),
                const SizedBox(height: 10),
              ],
            ),
          // check if all profiles are in a group
          if (!(widget.profiles.isNotEmpty &&
              widget.trip.rentalCars.isNotEmpty &&
              widget.profiles.every((profile) => widget.trip.rentalCars
                  .any((group) => group.members.contains(profile.id))) &&
              widget.trip.rentalCars
                  .every((group) => group.members.isNotEmpty)))
            ElevatedButton(
              onPressed: () async {
                RentalCarGroup newGroup = await widget.trip
                    .createRentalCarGroup(
                        "Group ${widget.trip.rentalCars.length + 1}",
                        List<String>.empty(growable: true));
                if (!isMobile) {
                  widget.setCurrentGroup(newGroup);
                }
                if (mounted) {
                  setState(() {});
                }
              },
              child: const Text("Create New Group"),
            ),
        ]),
      ),
    );
  }
}
