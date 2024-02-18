import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/events/event_info_dialog.dart';
import 'package:tripsitter/components/events/events_options.dart';
import 'package:tripsitter/components/mobile_wrapper.dart';

class EventsItinerary extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;
  final Function? setState;
  const EventsItinerary({required this.trip, required this.profiles, this.setState, super.key});

  @override
  State<EventsItinerary> createState() => _EventsItineraryState();
}

class _EventsItineraryState extends State<EventsItinerary> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = Provider.of<bool>(context);
    return ListView(
      children: [
        Text('Itinerary', style: Theme.of(context).textTheme.displayMedium?.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
        ...widget.trip.activities.map((activity) => Builder(
          builder: (context) {
            bool remove = widget.profiles.every((profile) => activity.participants.contains(profile.id));
            return Card(
              child: ListTile(
                  title: Text(activity.event.name),
                  isThreeLine: true,
                  visualDensity: VisualDensity(vertical: 4), // to expand
                  subtitle: Text('${activity.event.venues.firstOrNull?.name}\n${activity.event.startTime.localDate} ${activity.event.startTime.localTime}'),
                  trailing: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.info),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return EventPopup(activity.event);
                                },
                              );
                            }
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await widget.trip.removeActivity(activity);
                              setState(() {});
                              if(widget.setState != null) {
                                widget.setState!();
                              }
                            },
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                      SizedBox(height: 3),
                      PopupMenuButton<UserProfile>(
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              value: UserProfile(id: "id", name: "name", email: "email", hometown: null, numberTrips: 0, joinDate: DateTime.now()),
                              child: Text("${remove ? "Remove" : "Add"} all", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            ...widget.profiles.map((UserProfile profile) => PopupMenuItem(
                            value: profile,
                            child: Row(
                              children: [
                                if(activity.participants.contains(profile.id))
                                  Icon(Icons.check),
                                if(!activity.participants.contains(profile.id))
                                  Icon(Icons.add),
                                Text(profile.name),
                              ],
                            ),
                          )).toList()
                          ];
                        },
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Participants"),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(5),
                          )
                        ),
                        onSelected: (UserProfile profile) async {
                          print("Selected $profile");
                          if(profile.id == "id") {
                            print("ADD/REMOVE ALL");
                            for(UserProfile profile in widget.profiles) {
                              if(!remove && !activity.participants.contains(profile.id)) {
                                await activity.addParticipant(profile.id);
                              }
                              else if(remove && activity.participants.contains(profile.id)) {
                                await activity.removeParticipant(profile.id);
                              }
                            }
                          }
                          else {
                            print("Adding ${profile.name}");
                            if(activity.participants.contains(profile.id)) {
                              await activity.removeParticipant(profile.id);
                            } else {
                              await activity.addParticipant(profile.id);
                            }
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
            );
          }
        )).toList(),
        if(isMobile)
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(title: "Add Event", child: EventsOptions(trip: widget.trip, profiles: widget.profiles, setState: () {
              setState(() {});
              if(widget.setState != null) {
                widget.setState!();
              }
            })))),
            child: const Text('Add Event'),
          )
      ]
    );
  }
}