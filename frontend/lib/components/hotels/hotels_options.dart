import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/airport.dart';
import 'package:tripsitter/classes/counter.dart';
import 'package:tripsitter/classes/filterbutton.dart';
import 'package:tripsitter/classes/hotels.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/hotels/hotel_info_dialog.dart';
import 'package:tripsitter/components/map.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/helpers/data.dart';
import 'package:tripsitter/helpers/locators.dart';
import 'package:tripsitter/popups/checkbox_popup.dart';
import 'package:tripsitter/popups/counter_popup.dart';
import 'package:tripsitter/popups/select_popup.dart';

class HotelOptions extends StatefulWidget {
  final Trip trip;
  final HotelGroup? currentGroup;
  final Function setState;
  const HotelOptions(
      {required this.currentGroup,
      required this.setState,
      required this.trip,
      super.key});

  @override
  State<HotelOptions> createState() => _HotelOptionsState();
}

enum HotelSortOption {
  price,
  distance;

  @override
  String toString() {
    switch (this) {
      case HotelSortOption.price:
        return 'Price';
      case HotelSortOption.distance:
        return 'Distance to Airport';
    }
  }
}

class _HotelOptionsState extends State<HotelOptions> {
  @override
  void initState() {
    super.initState();
    getHotels();
    getAirports(context).then((value) {
      if(widget.trip.flights.isEmpty || widget.trip.flights.first.selected == null) return;
      arrivalAirport = value.firstWhereOrNull((element) => element.iataCode == widget.trip.flights.first.arrivalAirport);
      sortHotels();
    });
  }

  List<HotelOption> hotels = [];

  void getHotels() async {
    HotelQuery query = HotelQuery(
      latitude: widget.trip.destination.lat,
      longitude: widget.trip.destination.lon,
      checkInDate: DateFormat("yyyy-MM-dd").format(widget.trip.startDate),
      checkOutDate: DateFormat("yyyy-MM-dd").format(widget.trip.endDate),
      adults: 1,
    );
    hotels = await TripsitterApi.getHotels(query);
    final Set<String> bedTypes = {};
    for (var hotel in hotels) {
      for (var offer in hotel.offers) {
        if(offer.room?.typeEstimated?.bedType != null) {
          bedTypes.add(offer.room!.typeEstimated!.bedType!);
        }
      }
    }

    final bedList = bedTypes.toList();
    bedList.sort((a, b) => a.compareTo(b));
    _selectedbedTypes = [...bedList];
    sortHotels();
    // for(HotelOption hotel in hotels) {
    // debugPrint(hotel.offers.first.toJson());
    // }
    if (!mounted) return;
    setState(() {});
  }

  String? minPrice(List<HotelOffer> offers) {
    List<String> prices =
        offers.map((o) => o.price.total).whereNotNull().toList();
    return prices.isEmpty
        ? null
        : prices.map((p) => double.parse(p)).reduce(min).toString();
  }

  int minBeds = 1;
  List<String> _selectedbedTypes = [];

  bool _sortDirection = true;
  bool _isBedCountOpen = false;
  bool _isBedTypeOpen = false;
  final GlobalKey _sortKey = GlobalKey();
  final GlobalKey _bedCountKey = GlobalKey();
  final GlobalKey _bedTypeKey = GlobalKey();
  HotelSortOption _selectedSort = HotelSortOption.price;

  void _showCountPopup() async {
    setState(() {
      _isBedCountOpen = true;
    });
    List<CounterVariable> variables = [
      CounterVariable(name: "Min # of Beds", value: minBeds),
    ];

    // Show the popup and await the modified variables
    final List<CounterVariable> updatedVariables = await showCounterPopup(
      context: context,
      key: _bedCountKey,
      variables: variables,
    );
    setState(() {
      minBeds = updatedVariables
          .firstWhere((variable) => variable.name == "Min # of Beds")
          .value;
      _isBedCountOpen = false;
    });
  }

  void _showTypePopup() async {
    if(hotels.isEmpty) return;
    setState(() {
      _isBedTypeOpen = true;
    });

    final Set<String> bedTypes = {};
    for (var hotel in hotels) {
      for (var offer in hotel.offers) {
        if(offer.room?.typeEstimated?.bedType != null) {
          bedTypes.add(offer.room!.typeEstimated!.bedType!);
        }
      }
    }

    final bedList = bedTypes.toList();
    bedList.sort((a, b) => a.compareTo(b));

    final popup = CheckboxPopup(
      options: bedList,
      format: (String option) => option[0] + option.substring(1).toLowerCase(),
      selected: _selectedbedTypes,
      onSelected: (List<String> newSelected) {
        setState(() {
          _selectedbedTypes = newSelected;
          // getFlights(reset: false);
        });
      },
    );

    popup.showPopup(context, _bedTypeKey).then((_) {
      setState(() {
        _isBedTypeOpen = false;
      });
    });
  }

  void _showSortPopup() {
    setState(() {
    });

    final popup = SelectOnePopup<HotelSortOption>(
      options: HotelSortOption.values,
      selected: _selectedSort,
      onSelected: (HotelSortOption value) {
        setState(() {
          _selectedSort = value;
          sortHotels();
        });
      },
    );

    popup.showPopup(context, _sortKey).then((_) {
      setState(() {
      });
    });
  }

  sortHotels() {
    hotels.sort(compareHotels);
  }

  int compareHotels(HotelOption a, HotelOption b) {
    switch (_selectedSort) {
      case HotelSortOption.price:
        return _sortDirection
            ? double.parse(minPrice(a.offers) ?? "0.0").compareTo(double.parse(minPrice(b.offers) ?? "0"))
            : double.parse(minPrice(b.offers) ?? "0.0").compareTo(double.parse(minPrice(a.offers) ?? "0"));
      case HotelSortOption.distance:
        if(arrivalAirport == null) return 0;
        return !_sortDirection
            ? distance(a.hotel.latitude ?? 0, a.hotel.longitude ?? 0, arrivalAirport!.lat, arrivalAirport!.lon).compareTo(distance(b.hotel.latitude ?? 0, b.hotel.longitude ?? 0, arrivalAirport!.lat, arrivalAirport!.lon))
            : distance(b.hotel.latitude ?? 0, b.hotel.longitude ?? 0, arrivalAirport!.lat, arrivalAirport!.lon).compareTo(distance(a.hotel.latitude ?? 0, a.hotel.longitude ?? 0, arrivalAirport!.lat, arrivalAirport!.lon));

    }
  }

  Airport? arrivalAirport;

  bool mapSelected = false;

  List<HotelOption> get hotelsFiltered {
    return hotels.where((hotel) {
      if(hotel.offers.isEmpty) return false;
      if(hotel.offers.map((o) => o.room?.typeEstimated?.bedType).whereNotNull().isEmpty) return false;
      if(hotel.offers.map((o) => o.room?.typeEstimated?.bedType).whereNotNull().any((t) => !_selectedbedTypes.contains(t))) return false;
      if(hotel.offers.map((o) => o.room?.typeEstimated?.beds).whereNotNull().any((c) => c < minBeds)) return false;
      return true;
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    bool isMobile = Provider.of<bool>(context, listen: false);
    return widget.currentGroup == null
        ? const Center(child: Text("Select or create a group to choose a hotel"))
        : Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Text("Hotels for ${widget.currentGroup!.name}",
              //     style: Theme.of(context).textTheme.displayMedium?.copyWith(
              //         decoration: TextDecoration.underline,
              //         fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text("Hotels for ${widget.currentGroup!.name}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                            text: '# Beds',
                            globalKey: _bedCountKey,
                            onPressed: _showCountPopup,
                            icon: Icon(
                              _isBedCountOpen
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                            )),
                        FilterButton(
                            text: 'Bed Type',
                            globalKey: _bedTypeKey,
                            onPressed: _showTypePopup,
                            icon: Icon(
                              _isBedTypeOpen
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
                          sortHotels();
                        });
                      },
                      icon: Icon(_sortDirection
                          ? Icons.arrow_upward
                          : Icons.arrow_downward),
                    )),
                ],
              ),
              if(mapSelected)
                TripsitterMap<HotelOption>(
                  items: hotelsFiltered, 
                  isSelected: (dynamic h) => (widget.currentGroup!.selectedInfo?.hotelId == (h as HotelOption).hotel.hotelId),
                  isOption: (dynamic h) => (widget.currentGroup!.infos.isNotEmpty && widget.currentGroup!.infos.map((c) => c.hotelId).contains((h as HotelOption).hotel.hotelId)),
                  isOther: (dynamic h) => (widget.trip.hotels.map((g) => g.selectedInfo?.hotelId).contains((h as HotelOption).hotel.hotelId)),
                  extras: const [
                    MarkerType.airport,
                    MarkerType.restaurant,
                    MarkerType.activity
                  ],
                  trip: widget.trip, 
                  getLat: (dynamic h) => (h as HotelOption).hotel.latitude ?? 0.0, 
                  getLon: (dynamic h) => (h as HotelOption).hotel.longitude ?? 0.0
                ),
              if(!mapSelected)
                Expanded(
                  child: ListView(
                    children: [
                      for (int i = 0; i < (mapSelected ? 0 : hotelsFiltered.length); i++)
                        ExpansionTile(
                          title: ListTile(
                            // leading: Image.network("https://logos.skyscnr.com/images/carhire/sippmaps/${car.group.img}", width: 80, height: 80),
                            title: Text(hotelsFiltered[i].hotel.name),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                icon: const Icon(Icons.info),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return HotelInfoDialog(hotelsFiltered[i].hotel);
                                      });
                                },
                              ),
                            ]),
                            subtitle: Text(minPrice(hotelsFiltered[i].offers) != null
                                ? "From \$${minPrice(hotelsFiltered[i].offers)}"
                                : "No price available"),
                          ),
                          children: hotelsFiltered[i].offers.map((HotelOffer o) {
                            return ListTile(
                              subtitle: Text(o.room?.description?.text ??
                                  "No description available"),
                              title: o.price.total == null
                                  ? null
                                  : Text("\$${o.price.total}"),
                              trailing: ElevatedButton(
                                onPressed: () async {
                                  if (widget.currentGroup!.infos.isNotEmpty &&
                                      widget.currentGroup!.infos
                                          .map((c) => c.hotelId)
                                          .contains(hotelsFiltered[i].hotel.hotelId)) {
                                    await widget.currentGroup!.removeOption(widget
                                        .currentGroup!.infos
                                        .indexWhere((element) =>
                                            element.hotelId ==
                                            hotelsFiltered[i].hotel.hotelId));
                                  } else {
                                    await widget.currentGroup!
                                        .addOption(hotelsFiltered[i].hotel, o);
                                  }
                                  setState(() {});
                                  widget.setState();
                                  if(isMobile && mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text(
                                    "Select${(widget.currentGroup!.infos.isNotEmpty && widget.currentGroup!.infos.map((c) => c.hotelId).contains(hotels[i].hotel.hotelId)) ? "ed" : ""}"),
                              ),
                            );
                          }).toList(),
                        ),
                    ]
                  ),
                ),
              
            ],
          ),
        );
  }
}
