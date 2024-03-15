import 'dart:math';

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/airport.dart';
import 'package:tripsitter/classes/filterbutton.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/events/event_info_dialog.dart';
import 'package:tripsitter/components/map.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/helpers/data.dart';
import 'package:tripsitter/helpers/locators.dart';
import 'package:tripsitter/popups/checkbox_popup.dart';
import 'package:tripsitter/popups/select_popup.dart';

class EventsOptions extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;
  final Map<String, GlobalKey> participantsPopupKeys;
  final Map<String, List<String>> selectedParticipantsMap;
  final Map<String, bool> participantsPopupOpenState;
  final Function? setState;

  const EventsOptions({
    required this.trip,
    required this.profiles,
    required this.participantsPopupKeys,
    required this.selectedParticipantsMap,
    required this.participantsPopupOpenState,
    this.setState,
    super.key,
  });

  @override
  State<EventsOptions> createState() => _EventsOptionsState();
}

enum EventSortOption {
  price,
  distanceAirport,
  distanceHotel;

  @override
  String toString() {
    switch (this) {
      case EventSortOption.price:
        return 'Price';
      case EventSortOption.distanceAirport:
        return 'Distance to Airport';
      case EventSortOption.distanceHotel:
        return 'Distance to Hotel';
    }
  }
}

class _EventsOptionsState extends State<EventsOptions>
    with TickerProviderStateMixin {
  List<TicketmasterEvent> events = [];
  Trip get trip => widget.trip;

  late AnimationController controller;

  bool isLoaded = true;

  bool mapSelected = false;

  @override
  void initState() {
    isLoaded = false;
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    super.initState();
    super.initState();
    getEvents();
    getAirports(context).then((value) {
      if (widget.trip.flights.isEmpty ||
          widget.trip.flights.first.selected == null) return;
      arrivalAirport = value.firstWhereOrNull((element) =>
          element.iataCode == widget.trip.flights.first.arrivalAirport);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<String> selectedGenres = [];
  bool _sortDirection = true;
  bool _isGenreOpen = false;
  final GlobalKey _sortKey = GlobalKey();
  final GlobalKey _genreKey = GlobalKey();
  EventSortOption _selectedSort = EventSortOption.price;

  Future<void> getEvents() async {
    debugPrint("Getting events for trip ${trip.id}");
    List<TicketmasterEvent> call =
        await TripsitterApi.getEvents(TicketmasterQuery(
      lat: trip.destination.lat,
      long: trip.destination.lon,
      startDateTime: trip.startDate,
      endDateTime: trip.endDate,
    ));
    call.sort(compareEvents);

    Set<String> genres = {};
    for (TicketmasterEvent e in call) {
      for (TicketmasterClassification c in e.classifications) {
        if (c.genre != null) {
          genres.add(c.genre!.name);
        }
      }
    }
    debugPrint(genres.toList().toString());
    // After fetching events, initialize GlobalKeys for each
    setState(() {
      selectedGenres = genres.toList();
      events = call;
    });

    isLoaded = true;
  }

  void _showGenrePopup() async {
    if (events.isEmpty) return;
    setState(() {
      _isGenreOpen = true;
    });

    Set<String> genres = {};
    for (TicketmasterEvent e in events) {
      for (TicketmasterClassification c in e.classifications) {
        if (c.genre != null) {
          genres.add(c.genre!.name);
        }
      }
    }

    final genresList = genres.toList();
    genresList.sort((a, b) => a.compareTo(b));

    final popup = CheckboxPopup(
      options: genresList,
      format: (String option) => option[0] + option.substring(1).toLowerCase(),
      selected: selectedGenres,
      onSelected: (List<String> newSelected) {
        setState(() {
          selectedGenres = newSelected;
          // getFlights(reset: false);
        });
      },
    );

    popup.showPopup(context, _genreKey).then((_) {
      setState(() {
        _isGenreOpen = false;
      });
    });
  }

  bool filterEvents(TicketmasterEvent event) {
    double distanceFromAirport = 0;
    if (arrivalAirport != null) {
      distanceFromAirport = distance(
          event.venues.first.latitude ?? 0,
          event.venues.first.longitude ?? 0,
          arrivalAirport!.lat,
          arrivalAirport!.lon);
    }
    if (distanceFromAirport > 150) {
      return false;
    }
    if (selectedGenres.isEmpty) return true;
    for (TicketmasterClassification c in event.classifications) {
      if (c.genre != null && selectedGenres.contains(c.genre!.name)) {
        return true;
      }
    }
    return false;
  }

  Airport? arrivalAirport;

  int compareEvents(TicketmasterEvent a, TicketmasterEvent b) {
    switch (_selectedSort) {
      case EventSortOption.price:
        return a.prices.isEmpty
            ? 1
            : b.prices.isEmpty
                ? -1
                : a.prices
                    .map((p) => p.min)
                    .reduce(min)
                    .compareTo(b.prices.map((p) => p.min).reduce(min));
      case EventSortOption.distanceAirport:
        if (arrivalAirport == null) return 0;
        return a.venues.isEmpty
            ? 1
            : b.venues.isEmpty
                ? -1
                : distance(
                        a.venues.first.latitude ?? 0,
                        a.venues.first.longitude ?? 0,
                        arrivalAirport!.lat,
                        arrivalAirport!.lon)
                    .compareTo(distance(
                        b.venues.first.latitude ?? 0,
                        b.venues.first.longitude ?? 0,
                        arrivalAirport!.lat,
                        arrivalAirport!.lon));
      case EventSortOption.distanceHotel:
        if (trip.hotels.isEmpty || trip.hotels.first.selectedInfo == null)
          return 0;
        return a.venues.isEmpty
            ? 1
            : b.venues.isEmpty
                ? -1
                : distance(
                        a.venues.first.latitude ?? 0,
                        a.venues.first.longitude ?? 0,
                        trip.hotels.first.selectedInfo!.latitude ?? 0,
                        trip.hotels.first.selectedInfo!.longitude ?? 0)
                    .compareTo(distance(
                        b.venues.first.latitude ?? 0,
                        b.venues.first.longitude ?? 0,
                        trip.hotels.first.selectedInfo!.latitude ?? 0,
                        trip.hotels.first.selectedInfo!.longitude ?? 0));
      // return a.venues.isEmpty
      //     ? 1
      //     : b.venues.isEmpty
      //         ? -1
      //         : a.venues.firstOrNull?.distanceToHotel.compareTo(
      //             b.venues.firstOrNull?.distanceToHotel);
    }
  }

  void _showSortPopup() {
    setState(() {});

    final popup = SelectOnePopup<EventSortOption>(
      options: EventSortOption.values,
      selected: _selectedSort,
      onSelected: (EventSortOption value) {
        setState(() {
          _selectedSort = value;
          events.sort(compareEvents);
        });
      },
    );

    popup.showPopup(context, _sortKey).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Provider.of<bool>(context, listen: false);
    int rowIndex = 0;
    // Initialize a counter variable before mapping the events to TableRows
    return Column(
      children: [
        // Text("Choose Activities",
        //     style: Theme.of(context)
        //         .textTheme
        //         .displayMedium
        //         ?.copyWith(fontWeight: FontWeight.bold)),
        Wrap(
          children: [
            const Text("Choose Activities",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Row(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(80, 10, 0, 0),
                child: Text("Toggle Map Mode",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          decoration: TextDecoration.none,
                          fontSize: 12,
                        )),
              ),
              Switch(
                value: mapSelected,
                onChanged: (bool value) {
                  setState(() {
                    mapSelected = value;
                  });
                },
              ),
            ],)
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 10,
                children: <Widget>[
                  FilterButton(
                      text: 'Genre',
                      globalKey: _genreKey,
                      onPressed: _showGenrePopup,
                      icon: Icon(
                        _isGenreOpen
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                      )),
                ],
              ),
            ),
            if(!mapSelected)
            FilterButton(
                color: Colors.grey[100]!,
                text: _selectedSort.toString(),
                globalKey: _sortKey,
                onPressed: _showSortPopup,
                icon: IconButton(
                  onPressed: () {
                    setState(() {
                      _sortDirection = !_sortDirection;
                    });
                  },
                  icon: Icon(_sortDirection
                      ? Icons.arrow_upward
                      : Icons.arrow_downward),
                )),
          ],
        ),
        !isLoaded
            ? Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: controller.value,
                    strokeWidth: 20,
                    semanticsLabel: 'Circular progress indicator',
                  ),
                ),
              )
            : mapSelected
                ? TripsitterMap<TicketmasterEvent>(
                    trip: trip,
                    extras: const [
                      MarkerType.airport,
                      MarkerType.hotel,
                      MarkerType.restaurant
                    ],
                    isSelected: (dynamic event) => trip.activities
                                .map((e) => e.event.id)
                                .contains((event as TicketmasterEvent).id),
                    getLat: (dynamic e) => (e as TicketmasterEvent).venues.first.latitude ?? 0,
                    getLon: (dynamic e) => (e as TicketmasterEvent).venues.first.longitude ?? 0,
                    items: (_sortDirection ? events : events.reversed)
                        .where(filterEvents)
                        .toList()
                )
                : Expanded(
                  child: ImplicitlyAnimatedList<TicketmasterEvent>(
                    insertDuration: const Duration(milliseconds: 350),
                    removeDuration: const Duration(milliseconds: 350),
                    updateDuration: const Duration(milliseconds: 350),
                    areItemsTheSame: (a, b) => a.id == b.id,
                    items: (_sortDirection ? events : events.reversed)
                            .where(filterEvents).toList(),
                    itemBuilder: (context, animation, event, i){
                          Color bgColor = rowIndex % 2 == 0
                              ? Colors.grey[200]! // Light gray color
                              : Colors.white; // White color
                    
                          // Increment the row index for the next iteration
                          rowIndex++;
                          return SizeFadeTransition(
                            sizeFraction: 0.8,
                            curve: Curves.easeInOut,
                            animation: animation,
                            child: Container(
                              color: bgColor,
                              child: ListTile(
                                  leading: isMobile ? null : event.images.isEmpty
                                          ? const Icon(Icons.star)
                                          : Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: AspectRatio(aspectRatio: 1.0, child: Image.network(event.images.first.url)),
                                          ),
                                  title: isMobile ? Wrap(
                                    spacing: 5.0,
                                    children: [
                                      Text(event.name),
                                      Text(event.prices.isEmpty ? "" : "(From \$${event.prices.map((p) => p.min).reduce(min)}/person)")
                                    ],
                                  ) : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          children: [
                                            Text(event.name),
                                            Text(event.prices.isEmpty ? "" : "From \$${event.prices.map((p) => p.min).reduce(min)}/person"),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${event.venues.firstOrNull?.name}\nStarts ${event.startTime.localDate} ${event.startTime.localTime}'
                                        ),
                                      )
                                    ],
                                  ),
                                  subtitle: isMobile ? Wrap(
                                    spacing: 5.0,
                                    children: [
                                      Text(event.venues.firstOrNull?.name ?? ""),
                                      Text("(Starts ${event.startTime.localDate} ${event.startTime.localTime})")
                                    ],
                                  ) : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.info),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return EventPopup(event);
                                            },
                                          );
                                        }
                                      ),
                                      Builder(builder: (context) {
                                        bool selected = trip.activities
                                            .map((e) => e.event.id)
                                            .contains(event.id);
                                        return GestureDetector(
                                          onTap: selected
                                              ? () async {
                                                print("Removing activity");
                                                  await trip.removeActivity(trip
                                                      .activities
                                                      .firstWhere((a) =>
                                                          a.event.id == event.id));
                                                  setState(() {});
                                                  if (widget.setState != null) {
                                                    widget.participantsPopupOpenState[
                                                        event.id] = true;
                                                    widget.selectedParticipantsMap
                                                        .remove(event.id);
                                                    widget.participantsPopupKeys
                                                        .remove(event.id);
                                                    widget.setState!();
                                                  }
                                                }
                                              : () async {
                                                  print("Adding activity");
                                                  await trip.addActivity(
                                                      event,
                                                      widget.profiles
                                                          .map((e) => e.id)
                                                          .toList());
                                                  setState(() {});
                                                  if (widget.setState != null) {
                                                    widget.participantsPopupOpenState[
                                                        event.id] = false;
                                                    widget.selectedParticipantsMap[
                                                            event.id] =
                                                        widget.profiles
                                                            .map((e) => e.id)
                                                            .toList();
                                                    widget.participantsPopupKeys[
                                                        event.id] = GlobalKey();
                                                    widget.setState!();
                                                  }
                                                },
                                          child: Checkbox(
                                            value: selected,
                                            onChanged: null,
                                            fillColor: MaterialStateProperty.all<Color>(
                                                selected
                                                    ? const Color.fromARGB(
                                                        255, 127, 166, 198)
                                                    : Colors.grey[300]!),
                                            // style: ButtonStyle(
                                            //     backgroundColor:
                                            //         MaterialStateProperty.all<Color>(
                                            //             selected
                                            //                 ? const Color.fromARGB(
                                            //                     255, 127, 166, 198)
                                            //                 : Colors.grey[300]!)),
                                            // child: Text('Select${selected ? 'ed' : ''}',
                                            //     style: const TextStyle(
                                            //         color: Colors.black)),
                                          ),
                                        );
                                      })
                                    ],
                                  ),
                                ),
                            ),
                          );
                        })
                  ),

      ],
    );
  }
}
