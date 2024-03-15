import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/airport.dart';
import 'package:tripsitter/classes/filterbutton.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/classes/yelp.dart';
import 'package:tripsitter/components/map.dart';
import 'package:tripsitter/components/restaurants/restaurant_info_dialog.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/helpers/data.dart';
import 'package:tripsitter/helpers/locators.dart';
import 'package:tripsitter/popups/checkbox_popup.dart';
import 'package:tripsitter/popups/select_popup.dart';

class RestaurantsOptions extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;
  final Map<String, GlobalKey> participantsPopupKeys;
  final Map<String, List<String>> selectedParticipantsMap;
  final Map<String, bool> participantsPopupOpenState;
  final Function? setState;

  const RestaurantsOptions({
    required this.trip,
    required this.profiles,
    required this.participantsPopupKeys,
    required this.selectedParticipantsMap,
    required this.participantsPopupOpenState,
    this.setState,
    super.key,
  });

  @override
  State<RestaurantsOptions> createState() => _RestaurantsOptionsState();
}

enum RestaurantSortOption {
  price,
  distanceAirport,
  distanceHotel;

  @override
  String toString() {
    switch (this) {
      case RestaurantSortOption.price:
        return 'Price';
      case RestaurantSortOption.distanceAirport:
        return 'Distance to Airport';
      case RestaurantSortOption.distanceHotel:
        return 'Distance to Hotel';
    }
  }
}

class _RestaurantsOptionsState extends State<RestaurantsOptions>
    with TickerProviderStateMixin {
  List<YelpRestaurant> restaurants = [];
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
    getRestaurants();
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

  List<String> selectedCategorys = [];
  bool _sortDirection = true;
  bool _isCategoryOpen = false;
  final GlobalKey _sortKey = GlobalKey();
  final GlobalKey _genreKey = GlobalKey();
  RestaurantSortOption _selectedSort = RestaurantSortOption.price;

  Future<void> getRestaurants() async {
    debugPrint("Getting restaurants for trip ${trip.id}");
    List<YelpRestaurant> call =
        await TripsitterApi.getRestaurants(trip.destination);
    call.sort(compareRestaurants);

    Set<String> categories = {};
    for (YelpRestaurant e in call) {
      for (YelpCategory c in e.categories) {
        categories.add(c.title);
      }
    }
    debugPrint(categories.toList().toString());
    // After fetching restaurants, initialize GlobalKeys for each
    setState(() {
      selectedCategorys = categories.toList();
      restaurants = call;
    });

    isLoaded = true;
  }

  void _showCategoryPopup() async {
    if (restaurants.isEmpty) return;
    setState(() {
      _isCategoryOpen = true;
    });

    Set<String> categories = {};
    for (YelpRestaurant e in restaurants) {
      for (YelpCategory c in e.categories) {
        categories.add(c.title);
      }
    }

    final categoriesList = categories.toList();
    categoriesList.sort((a, b) => a.compareTo(b));

    final popup = CheckboxPopup(
      options: categoriesList,
      format: (String option) => option[0] + option.substring(1).toLowerCase(),
      selected: selectedCategorys,
      onSelected: (List<String> newSelected) {
        setState(() {
          selectedCategorys = newSelected;
          // getFlights(reset: false);
        });
      },
    );

    popup.showPopup(context, _genreKey).then((_) {
      setState(() {
        _isCategoryOpen = false;
      });
    });
  }

  bool filterRestaurants(YelpRestaurant restaurant) {
    double distanceFromAirport = 0;
    if (arrivalAirport != null) {
      distanceFromAirport = distance(
          restaurant.coordinates.latitude,
          restaurant.coordinates.longitude,
          arrivalAirport!.lat,
          arrivalAirport!.lon);
    }
    if (distanceFromAirport > 150) {
      return false;
    }
    if (selectedCategorys.isEmpty) return true;
    for (YelpCategory c in restaurant.categories) {
      if (selectedCategorys.contains(c.title)) {
        return true;
      }
    }
    return false;
  }

  Airport? arrivalAirport;

  int compareRestaurants(YelpRestaurant a, YelpRestaurant b) {
    switch (_selectedSort) {
      case RestaurantSortOption.price:
        return a.price == null
            ? 1
            : b.price == null
                ? -1
                : a.price!.compareTo(b.price!);
      case RestaurantSortOption.distanceAirport:
        if (arrivalAirport == null) return 0;
        return distance(
                        a.coordinates.latitude,
                        a.coordinates.longitude,
                        arrivalAirport!.lat,
                        arrivalAirport!.lon)
                    .compareTo(distance(
                        b.coordinates.latitude,
                        b.coordinates.longitude,
                        arrivalAirport!.lat,
                        arrivalAirport!.lon));
      case RestaurantSortOption.distanceHotel:
        if (trip.hotels.isEmpty || trip.hotels.first.selectedInfo == null)
          return 0;
        return distance(
                        a.coordinates.latitude,
                        a.coordinates.longitude,
                        trip.hotels.first.selectedInfo!.latitude ?? 0,
                        trip.hotels.first.selectedInfo!.longitude ?? 0)
                    .compareTo(distance(
                        b.coordinates.latitude ?? 0,
                        b.coordinates.longitude ?? 0,
                        trip.hotels.first.selectedInfo!.latitude ?? 0,
                        trip.hotels.first.selectedInfo!.longitude ?? 0));
      // return a.venues.isEmpty
      //     ? 1
      //     : b.venues.isEmpty
      //         ? -1
      //         : a.coordinatesOrNull?.distanceToHotel.compareTo(
      //             b.coordinatesOrNull?.distanceToHotel);
    }
  }

  void _showSortPopup() {
    setState(() {});

    final popup = SelectOnePopup<RestaurantSortOption>(
      options: RestaurantSortOption.values,
      selected: _selectedSort,
      onSelected: (RestaurantSortOption value) {
        setState(() {
          _selectedSort = value;
          restaurants.sort(compareRestaurants);
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
    // Initialize a counter variable before mapping the restaurants to TableRows
    return ListView(
      children: [
        // Text("Choose Restaurants",
        //     style: Theme.of(context)
        //         .textTheme
        //         .displayMedium
        //         ?.copyWith(fontWeight: FontWeight.bold)),
        Wrap(
          children: [
            const Text("Choose Restaurants",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 10,
                children: <Widget>[
                  FilterButton(
                      text: 'Category',
                      globalKey: _genreKey,
                      onPressed: _showCategoryPopup,
                      icon: Icon(
                        _isCategoryOpen
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                      )),
                ],
              ),
            ),
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
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return TripsitterMap<YelpRestaurant>(
                          items: (_sortDirection
                              ? restaurants
                              : restaurants.reversed)
                          .where(filterRestaurants).toList(), 
                          isSelected: (dynamic r) => trip.meals
                              .map((e) => e.restaurant.id)
                              .contains((r as YelpRestaurant).id),
                          extras: const [
                            MarkerType.airport,
                            MarkerType.hotel,
                            MarkerType.activity
                          ],
                          trip: trip, 
                          getLat: (dynamic r) => (r as YelpRestaurant).coordinates.latitude, 
                          getLon: (dynamic r) => (r as YelpRestaurant).coordinates.longitude
                        );
                      },
                    ),
                  )
                : Column(
                    children: [
                      for (YelpRestaurant restaurant in (_sortDirection
                              ? restaurants
                              : restaurants.reversed)
                          .where(filterRestaurants))
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(backgroundImage: NetworkImage(restaurant.imageUrl)),
                              title: Text(restaurant.name),
                              subtitle: Text(
                                  "${restaurant.price ?? ""}\n★ ${restaurant.rating.toString()}"),
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
                                                return RestaurantPopup(restaurant);
                                              },
                                            );
                                          }),
                                      Builder(builder: (context) {
                                        bool selected = trip.meals
                                            .map((e) => e.restaurant.id)
                                            .contains(restaurant.id);
                                        return ElevatedButton(
                                          onPressed: selected
                                              ? () async {
                                                  await trip.removeMeal(trip
                                                      .meals
                                                      .firstWhere((a) =>
                                                          a.restaurant.id == restaurant.id));
                                                  setState(() {});
                                                  if (widget.setState != null) {
                                                    widget.participantsPopupOpenState[
                                                        restaurant.id] = true;
                                                    widget.selectedParticipantsMap
                                                        .remove(restaurant.id);
                                                    widget.participantsPopupKeys
                                                        .remove(restaurant.id);
                                                    widget.setState!();
                                                  }
                                                }
                                              : () async {
                                                  await trip.addMeal(
                                                      restaurant,
                                                      widget.profiles
                                                          .map((e) => e.id)
                                                          .toList());
                                                  setState(() {});
                                                  if (widget.setState != null) {
                                                    widget.participantsPopupOpenState[
                                                        restaurant.id] = false;
                                                    widget.selectedParticipantsMap[
                                                            restaurant.id] =
                                                        widget.profiles
                                                            .map((e) => e.id)
                                                            .toList();
                                                    widget.participantsPopupKeys[
                                                        restaurant.id] = GlobalKey();
                                                    widget.setState!();
                                                  }
                                                },
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<Color>(
                                                      selected
                                                          ? const Color.fromARGB(
                                                              255, 127, 166, 198)
                                                          : Colors.grey[300]!)),
                                          child: Text('Select${selected ? 'ed' : ''}',
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
      ],
    );
  }
}
