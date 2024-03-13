import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/hotels.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/comments_popup.dart';
import 'package:tripsitter/components/hotels/hotel_info_dialog.dart';
import 'package:tripsitter/components/hotels/hotels_options.dart';
import 'package:tripsitter/components/mobile_wrapper.dart';
import 'package:google_fonts/google_fonts.dart';

class HotelGroups extends StatefulWidget {
  final List<UserProfile> profiles;
  final Trip trip;
  final HotelGroup? currentGroup;
  final Function setState;
  final Function(HotelGroup?) setCurrentGroup;

  const HotelGroups(
      {required this.setState,
      required this.profiles,
      required this.trip,
      required this.currentGroup,
      required this.setCurrentGroup,
      super.key});

  @override
  State<HotelGroups> createState() => _HotelGroupsState();
}

class _HotelGroupsState extends State<HotelGroups> {
  Trip get trip => widget.trip;

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);
    bool isMobile = Provider.of<bool>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(children: [
        // Text('Selections', style: Theme.of(context).textTheme.displayMedium?.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
        Center(
          child: Text(
            'Hotel Groups',
            style: GoogleFonts.kadwa(
              textStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
        ),
        for (HotelGroup group in widget.trip.hotels)
          Container(
              color: widget.currentGroup == group
                  ? Colors.blue[200]
                  : Colors.transparent,
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
                    subtitle: Text(group.members
                        .map((uid) =>
                            widget.profiles.firstWhere((e) => e.id == uid).name)
                        .join(", ")),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<UserProfile>(
                          itemBuilder: (BuildContext context) {
                            return widget.profiles
                                .where((profile) {
                                  for (HotelGroup g in widget.trip.hotels) {
                                    if (g.members.contains(profile.id) &&
                                        group != g) {
                                      return false;
                                    }
                                  }
                                  return true;
                                })
                                .map((UserProfile profile) => PopupMenuItem(
                                      value: profile,
                                      child: Row(
                                        children: [
                                          group.members.contains(profile.id)
                                              ? Icon(Icons.check)
                                              : Icon(Icons.add),
                                          Text(profile.name),
                                        ],
                                      ),
                                    ))
                                .toList();
                          },
                          child: Icon(Icons.add),
                          onSelected: (UserProfile profile) async {
                            print("Toggling ${profile.name}");
                            if (group.members.contains(profile.id)) {
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
                            icon: Icon(Icons.hotel)),
                        IconButton(
                            onPressed: () async {
                              await widget.trip.removeHotelGroup(group);
                              if (widget.currentGroup == group) {
                                widget.setCurrentGroup(null);
                              }
                              setState(() {});
                              widget.setState();
                            },
                            icon: Icon(Icons.delete)),
                      ],
                    ),
                  ),
                  for (int i = 0; i < group.infos.length; i++)
                    ListTile(
                      leading: Radio<HotelOffer>(
                        value: group.offers[i],
                        groupValue: group.selectedOffer,
                        onChanged: (HotelOffer? value) async {
                          if (value == null) return;
                          await group.selectOption(
                              group.infos[i], group.offers[i]);
                          setState(() {
                            widget.setState();
                          });
                        },
                      ),
                      title: Text(
                          "${group.infos[i].name} (\$${group.offers[i].price.total})"),
                      subtitle: Text(
                          "${group.offers[i].room?.description?.text ?? 'No description available'}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CommentsPopup(
                            comments: group.infos[i].comments,
                            profiles: widget.profiles,
                            myUid: user!.uid,
                            removeComment: (TripComment comment) async {
                              group.infos[i].removeComment(comment);
                              await trip.save();
                              if (mounted) {
                                setState(() {});
                              }
                            },
                            addComment: (String comment) async {
                              group.infos[i].addComment(TripComment(
                                  comment: comment,
                                  uid: user!.uid,
                                  date: DateTime.now()));
                              await trip.save();
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.info),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return HotelInfoDialog(group.infos[i]);
                                  });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await group.removeOption(i);
                              setState(() {});
                              widget.setState();
                            },
                          ),
                        ],
                      ),
                    ),
                  if (isMobile)
                    ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MobileWrapper(
                                      title: "Add Hotel Options",
                                      child: HotelOptions(
                                        currentGroup: group,
                                        trip: widget.trip,
                                        setState: () => setState(() {}),
                                      ))));
                        },
                        label: Text("Add Options")),
                  Divider(),
                ],
              )),
        // check if all profiles are in a group
        if (!(widget.profiles.length > 0 &&
            widget.trip.hotels.length > 0 &&
            widget.profiles.every((profile) => widget.trip.hotels
                .any((group) => group.members.contains(profile.id))) &&
            widget.trip.hotels.every((group) => group.members.length > 0)))
          ElevatedButton(
            onPressed: () async {
              HotelGroup newGroup = await widget.trip.createHotelGroup(
                  "Group ${widget.trip.hotels.length + 1}",
                  List<String>.empty(growable: true));
              if (!isMobile) {
                widget.setCurrentGroup(newGroup);
              }
              if (mounted) {
                setState(() {});
              }
            },
            child: Text("Create New Group"),
          ),
      ]),
    );
  }
}
