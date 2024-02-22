import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/classes/counter.dart';
import 'package:tripsitter/classes/filterbutton.dart';
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/flights/flight_dialog.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/helpers/formatters.dart';
import 'package:tripsitter/popups/checkbox_popup.dart';
import 'package:tripsitter/popups/counter_popup.dart';
import 'package:tripsitter/popups/select_popup.dart';

class FlightOptions extends StatefulWidget {
  final Trip trip;
  final FlightGroup? currentGroup;
  final List<UserProfile> profiles;
  final Function? setState;
  const FlightOptions({required this.trip, required this.currentGroup, required this.profiles, required this.setState, super.key});

  @override
  State<FlightOptions> createState() => _FlightOptionsState();
}

class _FlightOptionsState extends State<FlightOptions> {
  List<FlightItineraryRecursive>? flights = [];
  List<FlightItineraryRecursive> selected = [];

  List<FlightItineraryRecursive> originalFlights = [];

  final GlobalKey _stopsPopupKey = GlobalKey();
  final GlobalKey _airlinesPopupKey = GlobalKey();
  final GlobalKey _bagsPopupKey = GlobalKey();
  final GlobalKey _classPopupKey = GlobalKey();
  bool _isStopsPopupOpen = false;
  bool _isAirlinesPopupOpen = false;
  bool _isBagsPopupOpen = false;
  bool _isClassPopupOpen = false;

  String _selectedStops = 'Any number of stops';
  List<String> _selectedAirlines = [];
  int numCarryOnBags = 0;
  int numCheckedBags = 0;
  TravelClass _selectedClass = TravelClass.economy;

  int currentDepth = 0;

  void selectFlight(FlightItineraryRecursive flight) {
    setState(() {
      selected.add(flight);
      print("Select flight with ${flight.offers.length} offers");
      FlightOffer offer = flight.offers.first;
      currentDepth++;
      flights = flight.next;
      if((flights ?? []).isEmpty) {
        print("No more flights");
        currentGroup!.addOption(offer);
        flights = originalFlights;
        currentDepth = 0;
        widget.setState!();
      }
    });
  }
  FlightGroup? get currentGroup => widget.currentGroup;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FlightOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.currentGroup != widget.currentGroup) {
      getFlights();
    }
  }

  TravelClass selectedClass = TravelClass.economy;
  
  Future<void> getFlights({bool reset = true}) async {
    if(currentGroup == null) return;
    if(reset){
      setState(() {
        flights = null;
      });
    }
    print("Getting flights...");
    FlightsQuery query = FlightsQuery(
      origin: currentGroup!.departureAirport,
      destination: currentGroup!.arrivalAirport,
      departureDate: widget.trip.startDate,
      returnDate: widget.trip.endDate,
      adults: currentGroup!.members.length,
      travelClass: _selectedClass
    );
    List<FlightItineraryRecursive> flightsList = await TripsitterApi.getFlights(query);
    print("GOT ${flightsList.length} FLIGHTS");
    if(reset) {
      final Set<String> airlineCodes = {};
      for (var flight in flightsList) {
        for (var segment in flight.segments) {
          airlineCodes.add(segment.airlineOperating);
        }
      }
      final airlines = airlineCodes.toList();
      airlines.sort((a, b) => a.compareTo(b));
      _selectedAirlines = [];
      for (String airline in airlines) {
        _selectedAirlines.add(airline);
      }
    }
    if(!mounted) return;
    setState(() {
      currentDepth = 0;
      // flights.sort((a,b) => a.duration.toDuration().compareTo(b.duration));
      flights = flightsList;
      originalFlights = flightsList;
    });
  }

  bool filterFlight(FlightItineraryRecursive i) {
    if (_selectedStops == 'Nonstop only' && i.segments.length > 1) {
      return false;
    }
    if (_selectedStops == '1 stop or fewer' && i.segments.length > 2) {
      return false;
    }
    if (_selectedStops == '2 stops or fewer' && i.segments.length > 3) {
      return false;
    }
    if (_selectedAirlines.isNotEmpty) {
      // if any segment is not in the selected airlines, return false
      if (!i.segments.every((s) => _selectedAirlines.contains(s.airlineOperating))) {
        return false;
      }
    }
    // if (numCarryOnBags > 0 &&
    //     i.offers.first. < numCarryOnBags) {
    //   return false;
    // }
    // if (numCheckedBags > 0 &&
    //     i.offers.first.itineraries[i.depth].checkedBags < numCheckedBags) {
    //   return false;
    // }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if(currentGroup == null) {
      return Center(child: Text("Select a group to view flights"));
    }
    if(flights == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          if(currentDepth == 0)
            Text("Select Flight for ${currentGroup!.departureAirport} - ${currentGroup!.arrivalAirport}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          if(currentDepth > 0)
            Text("Select Flight for ${currentGroup!.arrivalAirport} - ${currentGroup!.departureAirport}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.0),
          Wrap(
            spacing: 10,
            children: <Widget>[
              FilterButton(
                  text: 'Stops',
                  globalKey: _stopsPopupKey,
                  onPressed: () => _showStopsPopup(),
                  icon: Icon(
                    _isStopsPopupOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                  )),
              FilterButton(
                  text: 'Airlines',
                  globalKey: _airlinesPopupKey,
                  onPressed: () => _showAirlinesPopup(),
                  icon: Icon(
                    _isAirlinesPopupOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                  )),
              FilterButton(
                  text: 'Bags',
                  globalKey: _bagsPopupKey,
                  onPressed: () => _showBagsPopup(),
                  icon: Icon(
                    _isBagsPopupOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                  )),
              FilterButton(
                  text: 'Class',
                  globalKey: _classPopupKey,
                  onPressed: () => _showClassPopup(),
                  icon: Icon(
                    _isClassPopupOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                  ))
            ],
          ),
          if(flights != null)
            Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
                4: FlexColumnWidth(),
                5: FlexColumnWidth(),
              },
              children: <TableRow>[
                ...flights!.where(filterFlight).map((flight) => TableRow(
                  children: <TableCell>[
                    TableCell(child: Stack(
                        children: flight.offers.first
                            .itineraries[flight.depth].segments
                            .map((s) =>
                                s.operating?.carrierCode ?? s.carrierCode)
                            .toSet()
                            .map((iata) =>
                                TripsitterApi.getAirlineImage(iata))
                            .toList())),
                    TableCell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "${flight.next.isNotEmpty ? "From " : ""}\$${flight.minPrice?.total ?? ''}"),
                          Text(
                              "Operated by ${flight.offers.first.itineraries[flight.depth].segments.map((s) => Airline.fromCode(s.operating?.carrierCode ?? s.carrierCode)?.name ?? s.operating?.carrierCode ?? s.carrierCode).toSet().join(", ")}"),
                        ],
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(DateFormat.jm().format(
                                    flight.segments.first.departure.at) +
                                " - " +
                                DateFormat.jm().format(
                                    flight.segments.last.arrival.at)),
                            Text(flight.itineraries.first.duration
                                .toDuration()
                                .format())
                          ],
                        ),
                      ),
                    ),
                    TableCell(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(flight.segments.length == 1
                              ? "Nonstop"
                              : "${(flight.segments.length - 1).toString()} stop${flight.segments.length > 2 ? "s" : ""}"),
                          flight.segments.length == 1
                              ? Text("")
                              : Text("Stops in " +
                                  flight.segments
                                      .sublist(1)
                                      .map((s) => s.departure.iataCode)
                                      .join(", ")),
                        ],
                      ),
                    ),
                    TableCell(child: IconButton(
                      icon: Icon(Icons.info_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => FlightDialog(flight)
                        );
                      },
                    )),
                    TableCell(
                      child: IconButton(
                        icon: Icon(currentDepth == 1 ? Icons.check : Icons.navigate_next_outlined),
                        onPressed: () {
                          selectFlight(flight);
                        },
                      ),
                    ),
                  ]))
                  .toList(),
              ]
            ),
        ],
      ),
    );
  }

  void _showStopsPopup() {
    setState(() {
      _isStopsPopupOpen = true;
    });

    final options = [
      'Any number of stops',
      'Nonstop only',
      '1 stop or fewer',
      '2 stops or fewer'
    ];

    final popup = SelectOnePopup(
      options: options,
      selected: _selectedStops,
      onSelected: (String value) {
        setState(() {
          _selectedStops = value;
          _isStopsPopupOpen = false;
          // getFlights(reset: false);
        });
      },
    );

    popup.showPopup(context, _stopsPopupKey).then((_) {
      setState(() {
        _isStopsPopupOpen = false;
      });
    });
  }

  void _showAirlinesPopup() async {
    setState(() {
      _isAirlinesPopupOpen = true;
    });
    if(flights == null) return;

    final Set<String> airlineCodes = {};
    for (var flight in flights!) {
      for (var segment in flight.segments) {
        airlineCodes.add(segment.airlineOperating);
      }
    }

    final airlines = airlineCodes.toList();
    airlines.sort((a, b) => a.compareTo(b));

    final popup = CheckboxPopup(
      options: airlines,
      format: (String option) => Airline.fromCode(option)?.name ?? option,
      selected: _selectedAirlines,
      onSelected: (List<String> newSelected) {
        setState(() {
          _selectedAirlines = newSelected;
          // getFlights(reset: false);
        });
      },
    );

    popup.showPopup(context, _airlinesPopupKey).then((_) {
      setState(() {
        _isAirlinesPopupOpen = false;
      });
    });
  }

  void _showBagsPopup() async {
    setState(() {
      _isBagsPopupOpen = true;
    });

    // Initialize your counter variables with the current state
    List<CounterVariable> variables = [
      CounterVariable(name: "Carry On Bags", value: numCarryOnBags),
      CounterVariable(name: "Checked Bags", value: numCheckedBags),
    ];

    // Show the popup and await the modified variables
    final List<CounterVariable> updatedVariables = await showCounterPopup(
      context: context,
      key: _bagsPopupKey,
      variables: variables,
    );

    // Update your state based on the returned values
    setState(() {
      numCarryOnBags = updatedVariables
          .firstWhere((variable) => variable.name == "Carry On Bags")
          .value;
      numCheckedBags = updatedVariables
          .firstWhere((variable) => variable.name == "Checked Bags")
          .value;
      _isBagsPopupOpen = false;
      getFlights();
    });
  }

  void _showClassPopup() {
    setState(() {
      _isClassPopupOpen = true;
    });

    final popup = SelectOnePopup<TravelClass>(
      options: TravelClass.values,
      selected: _selectedClass,
      onSelected: (TravelClass value) {
        setState(() {
          _selectedClass = value;
          _isClassPopupOpen = false;
          getFlights();
        });
      },
    );

    popup.showPopup(context, _classPopupKey).then((_) {
      setState(() {
        _isClassPopupOpen = false;
      });
    });
  }
}