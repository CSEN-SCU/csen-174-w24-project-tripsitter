import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/filterbutton.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/comments_popup.dart';
import 'package:tripsitter/components/mobile_wrapper.dart';
import 'package:tripsitter/components/restaurants/restaurant_info_dialog.dart';
import 'package:tripsitter/components/restaurants/restaurant_options.dart';
import 'package:tripsitter/popups/checkbox_popup.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantsItinerary extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;
  final Map<String, GlobalKey> participantsPopupKeys;
  final Map<String, List<String>> selectedParticipantsMap;
  final Map<String, bool> participantsPopupOpenState;
  final Function? setState;

  const RestaurantsItinerary({
    required this.trip,
    required this.profiles,
    required this.participantsPopupKeys,
    required this.selectedParticipantsMap,
    required this.participantsPopupOpenState,
    this.setState,
    super.key,
  });

  @override
  State<RestaurantsItinerary> createState() => _RestaurantsItineraryState();
}

class _RestaurantsItineraryState extends State<RestaurantsItinerary> {
  @override
  void initState() {
    super.initState();
    for (var meal in widget.trip.meals) {
      widget.participantsPopupKeys[meal.restaurant.id] = GlobalKey();
      widget.participantsPopupOpenState[meal.restaurant.id] = false;
    }
    for (var meal in widget.trip.meals) {
      widget.selectedParticipantsMap[meal.restaurant.id] =
          List.from(meal.participants);
    }
  }

// If your restaurants can change, update popupKeys accordingly

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);
    bool isMobile = Provider.of<bool>(context);
    return ListView(children: [
      // Text('Meals',
      //     style: Theme.of(context).textTheme.displayMedium?.copyWith(
      //         decoration: TextDecoration.underline,
      //         fontWeight: FontWeight.bold)),
      Center(
        child: Text(
          'Meals',
          style: GoogleFonts.kadwa(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
      ),

      ...widget.trip.meals
          .map((meal) => LayoutBuilder(builder: (context, constraints) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(meal.restaurant.imageUrl)),
                    title: Text(meal.restaurant.name),
                    subtitle: Text(
                        "${meal.restaurant.price ?? ""}\n★ ${meal.restaurant.rating.toString()}"),
                    visualDensity:
                        const VisualDensity(vertical: 4), // to expand
                    trailing: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.info),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return RestaurantPopup(meal.restaurant);
                                    },
                                  );
                                }),
                            CommentsPopup(
                              comments: meal.comments,
                              profiles: widget.profiles,
                              myUid: user!.uid,
                              removeComment: (TripComment comment) async {
                                await meal.removeComment(comment);
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              addComment: (String comment) async {
                                await meal.addComment(TripComment(
                                    comment: comment,
                                    uid: user.uid,
                                    date: DateTime.now()));
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await widget.trip.removeMeal(meal);
                                setState(() {});
                                if (widget.setState != null) {
                                  widget.setState!();
                                }
                              },
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: FilterButton(
                            text: 'Participants',
                            icon: Icon(
                              widget.participantsPopupOpenState[
                                          meal.restaurant.id] ??
                                      false
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                            ),
                            globalKey: widget.participantsPopupKeys[meal
                                .restaurant.id]!, // Use the meal's specific key
                            onPressed: () {
                              final mealId = meal.restaurant.id;
                              setState(() {
                                widget.participantsPopupOpenState[mealId] =
                                    true;
                              });
                              final participantOptions =
                                  widget.profiles.map((p) => p.name).toList();
                              final currentlySelected = widget.profiles
                                  .where((p) => widget
                                      .selectedParticipantsMap[mealId]!
                                      .contains(p.id))
                                  .map((p) => p.name)
                                  .toList();
                              CheckboxPopup(
                                options: participantOptions,
                                selected: currentlySelected,
                                onSelected: (List<String> selectedNames) {
                                  // Update the selected participants map based on names
                                  setState(() {
                                    widget.selectedParticipantsMap[mealId] =
                                        widget.profiles
                                            .where((profile) => selectedNames
                                                .contains(profile.name))
                                            .map((profile) => profile.id)
                                            .toList();

                                    // Update the actual meal participants to reflect changes
                                    meal.participants.clear();
                                    meal.participants.addAll(widget
                                        .selectedParticipantsMap[mealId]!);
                                  });
                                },
                                format: (s) => s.toString(),
                              )
                                  .showPopup(context,
                                      widget.participantsPopupKeys[mealId]!)
                                  .then((_) {
                                setState(() {
                                  widget.participantsPopupOpenState[
                                      mealId] = false;
                                });
                              });
                            },
                          ),
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
                      title: "Add Restaurants",
                      child: RestaurantsOptions(
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
          child: const Text('Add Restaurants'),
        )
    ]);
  }
}
