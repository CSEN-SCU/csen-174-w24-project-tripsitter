import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/filterbutton.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/events/event_info_dialog.dart';
import 'package:tripsitter/components/events/events_options.dart';
import 'package:tripsitter/components/mobile_wrapper.dart';
import 'package:tripsitter/popups/checkbox_popup.dart';

class EventsItinerary extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;
  final Map<String, GlobalKey> participantsPopupKeys;
  final Map<String, List<String>> selectedParticipantsMap;
  final Map<String, bool> participantsPopupOpenState;
  final Function? setState;

  const EventsItinerary({
    required this.trip,
    required this.profiles,
    required this.participantsPopupKeys,
    required this.selectedParticipantsMap,
    required this.participantsPopupOpenState,
    this.setState,
    super.key,
  });

  @override
  State<EventsItinerary> createState() => _EventsItineraryState();
}

class _EventsItineraryState extends State<EventsItinerary> {
  @override
  void initState() {
    super.initState();
    for (var activity in widget.trip.activities) {
      widget.participantsPopupKeys[activity.event.id] = GlobalKey();
      widget.participantsPopupOpenState[activity.event.id] = false;
    }
    widget.trip.activities.forEach((activity) {
      widget.selectedParticipantsMap[activity.event.id] =
          List.from(activity.participants);
    });
  }

// If your events can change, update popupKeys accordingly

  @override
  Widget build(BuildContext context) {
    bool isMobile = Provider.of<bool>(context);
    return ListView(children: [
      Text('Itinerary',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold)),
      ...widget.trip.activities
          .map((activity) => LayoutBuilder(builder: (context, constraints) {
                bool remove = widget.profiles.every(
                    (profile) => activity.participants.contains(profile.id));
                return Card(
                  child: ListTile(
                    title: Text(activity.event.name),
                    isThreeLine: true,
                    visualDensity: VisualDensity(vertical: 4), // to expand
                    subtitle: Text(
                        '${activity.event.venues.firstOrNull?.name}\n${activity.event.startTime.getFormattedDate()}'),
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
                                }),
                            ElevatedButton(
                              onPressed: () async {
                                await widget.trip.removeActivity(activity);
                                setState(() {});
                                if (widget.setState != null) {
                                  widget.setState!();
                                }
                              },
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        FilterButton(
                          text: 'Participants',
                          icon: Icon(
                            widget.participantsPopupOpenState[
                                        activity.event.id] ??
                                    false
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                          ),
                          globalKey: widget.participantsPopupKeys[activity
                              .event.id]!, // Use the activity's specific key
                          onPressed: () {
                            final activityId = activity.event.id;
                            setState(() {
                              widget.participantsPopupOpenState[activityId] =
                                  true;
                            });
                            final participantOptions =
                                widget.profiles.map((p) => p.name).toList();
                            final currentlySelected = widget.profiles
                                .where((p) => widget
                                    .selectedParticipantsMap[activityId]!
                                    .contains(p.id))
                                .map((p) => p.name)
                                .toList();
                            CheckboxPopup(
                              options: participantOptions,
                              selected: currentlySelected,
                              onSelected: (List<String> selectedNames) {
                                // Update the selected participants map based on names
                                setState(() {
                                  widget.selectedParticipantsMap[activityId] =
                                      widget.profiles
                                          .where((profile) => selectedNames
                                              .contains(profile.name))
                                          .map((profile) => profile.id)
                                          .toList();

                                  // Update the actual activity participants to reflect changes
                                  activity.participants.clear();
                                  activity.participants.addAll(widget
                                      .selectedParticipantsMap[activityId]!);
                                });
                              },
                              format: (s) => s.toString(),
                            )
                                .showPopup(context,
                                    widget.participantsPopupKeys[activityId]!)
                                .then((_) {
                              setState(() {
                                widget.participantsPopupOpenState[
                                    activityId] = false;
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }))
          .toList(),
      if (isMobile)
        ElevatedButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MobileWrapper(
                      title: "Add Event",
                      child: EventsOptions(
                          trip: widget.trip,
                          profiles: widget.profiles,
                          participantsPopupKeys: widget.participantsPopupKeys,
                          selectedParticipantsMap:
                              widget.selectedParticipantsMap,
                          participantsPopupOpenState:
                              widget.participantsPopupOpenState,
                          setState: () {
                            setState(() {});
                            if (widget.setState != null) {
                              widget.setState!();
                            }
                          })))),
          child: const Text('Add Event'),
        )
    ]);
  }
}
