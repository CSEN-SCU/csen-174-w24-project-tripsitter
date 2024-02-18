import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/classes/counter.dart';
import 'package:tripsitter/popups/checkbox_popup.dart';
import 'package:tripsitter/popups/counter_popup.dart';
import 'package:tripsitter/classes/filterbutton.dart';
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/popups/select_popup.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/helpers/formatters.dart';

class SelectFlight extends StatefulWidget {
  const SelectFlight({super.key});

  @override
  State<SelectFlight> createState() => _SelectFlightState();
}

class _SelectFlightState extends State<SelectFlight> {
  List<FlightItineraryRecursive> flights = [];
  List<FlightItineraryRecursive> selected = [];

  final GlobalKey _stopsPopupKey = GlobalKey();
  final GlobalKey _airlinesPopupKey = GlobalKey();
  final GlobalKey _bagsPopupKey = GlobalKey();
  bool _isStopsPopupOpen = false;
  bool _isAirlinesPopupOpen = false;
  bool _isBagsPopupOpen = false;

  String _selectedStops = 'Any number of stops';
  List<String> _selectedAirlines = [];
  int numCarryOnBags = 0;
  int numCheckedBags = 0;

  FlightsQuery query = FlightsQuery(
      origin: 'LAX',
      destination: 'SFO',
      departureDate: DateTime(2024, 6, 1),
      returnDate: DateTime(2024, 6, 5),
      adults: 1,
      travelClass: TravelClass.economy);

  int currentDepth = 0;

  void selectFlight(FlightItineraryRecursive flight) {
    setState(() {
      selected.add(flight);
      print("Select flight with ${flight.offers.length} offers");
      currentDepth++;
      flights = flight.next;
    });
  }

  late TextEditingController originController;
  late TextEditingController destinationController;
  late TextEditingController adultsController;
  late TextEditingController childrenController;

  @override
  void initState() {
    super.initState();
    originController = TextEditingController(text: query.origin);
    destinationController = TextEditingController(text: query.destination);
    adultsController = TextEditingController(text: query.adults.toString());
    childrenController =
        TextEditingController(text: query.children?.toString() ?? "");
    TripsitterApi.getFlights(query).then((flights) {
      print("GOT FLIGHTS ${flights.length}");
      final Set<String> airlineCodes = {};
      for (var flight in flights) {
        for (var segment in flight.segments) {
          airlineCodes.add(segment.airlineOperating);
        }
      }
      final airlines = airlineCodes
          .map((code) => Airline.fromCode(code)?.name ?? code)
          .toList();
      airlines.sort((a, b) => a.compareTo(b));
      for (String airline in airlines) {
        _selectedAirlines.add(airline);
        print('airline: $airline');
      }
      setState(() {
        // flights.sort((a,b) => a.duration.toDuration().compareTo(b.duration));
        this.flights = flights;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text("Select ${currentDepth == 0 ? "Outbound" : "Return"} Flight"),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: TextField(
                controller: originController,
                onChanged: (String value) {
                  setState(() {
                    query.origin = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Origin",
                  hintText: "LAX",
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                controller: destinationController,
                onChanged: (String value) {
                  setState(() {
                    query.destination = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Destination",
                  hintText: "SFO",
                ),
              ),
            ),
            // checkbox for one-way
            Checkbox(
                value: query.returnDate == null,
                onChanged: (bool? checked) => {
                      setState(() {
                        if (checked == true) {
                          query.returnDate = null;
                        } else {
                          query.returnDate = DateTime(2024, 6, 5);
                        }
                      })
                    }),
            Text("One-way"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                child: Text(DateFormat.yMMMMd().format(query.departureDate)),
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: query.departureDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      query.departureDate = date;
                    });
                  }
                },
              ),
            ),
            if (query.returnDate != null) Text(" - "),
            if (query.returnDate != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  child: Text(DateFormat.yMMMMd().format(query.returnDate!)),
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: query.returnDate!,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        query.returnDate = date;
                      });
                    }
                  },
                ),
              ),
            SizedBox(
              width: 100,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: adultsController,
                onChanged: (String value) {
                  setState(() {
                    query.adults = int.parse(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: "Adults",
                  hintText: "1",
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: childrenController,
                onChanged: (String value) {
                  setState(() {
                    query.children = int.parse(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: "Children",
                  hintText: "0",
                ),
              ),
            ),
            // dropdown for travelClass
            DropdownButton<TravelClass>(
              value: query.travelClass,
              onChanged: (TravelClass? value) {
                setState(() {
                  query.travelClass = value;
                });
              },
              items: TravelClass.values.map((TravelClass travelClass) {
                return DropdownMenuItem<TravelClass>(
                  value: travelClass,
                  child: Text(travelClass.name.toUpperCase()),
                );
              }).toList(),
            ),
            // submit
            ElevatedButton(
              onPressed: () {
                TripsitterApi.getFlights(query).then((flights) {
                  setState(() {
                    // flights.sort((a,b) => a.duration.compareTo(b.duration));
                    this.flights = flights;
                  });
                });
              },
              child: Text("Search"),
            ),
          ],
        ),
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
                ))
          ],
        ),
        DataTable(
          columns: [
            DataColumn(label: Text("")),
            DataColumn(label: Text("Price/Airline")),
            DataColumn(label: Text("Time")),
            DataColumn(label: Text("Stops")),
            DataColumn(label: Text("")),
          ],
          rows: flights
              .map((flight) => DataRow(
                      onSelectChanged: (bool? selected) {
                        if (selected == true) {
                          selectFlight(flight);
                        }
                      },
                      cells: [
                        DataCell(Stack(
                            children: flight
                                .offers.first.itineraries[flight.depth].segments
                                .map((s) =>
                                    s.operating?.carrierCode ?? s.carrierCode)
                                .toSet()
                                .map((iata) =>
                                    TripsitterApi.getAirlineImage(iata))
                                .toList())),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "${flight.next.isNotEmpty ? "From " : ""}\$${flight.minPrice?.total ?? ''}"),
                              // Text("Offered by ${flight.offeredBy.toSet().join(", ")}"),
                              Text(
                                  "Operated by ${flight.offers.first.itineraries[flight.depth].segments.map((s) => Airline.fromCode(s.operating?.carrierCode ?? s.carrierCode)?.name ?? s.operating?.carrierCode ?? s.carrierCode).toSet().join(", ")}"),
                            ],
                          ),
                        ),
                        DataCell(
                          Center(
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
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(flight.segments.length == 1
                                  ? "Nonstop"
                                  : "${(flight.segments.length - 1).toString()} stop${flight.segments.length > 2 ? "s" : ""}"),
                              // list all segment arrivalIataCodes in all but the first segment
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
                        DataCell(IconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Flight Details"),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int j = 0;
                                        j < flight.segments.length;
                                        j++) ...[
                                      Text("Flight ${j + 1}"),
                                      // LHR - SFO
                                      Text(
                                          "${flight.segments[j].departure.iataCode} - ${flight.segments[j].arrival.iataCode}"),
                                      Text(
                                          "Operated by ${Airline.fromCode(flight.segments[j].airlineOperating)?.name ?? flight.segments[j].airlineOperating}"),
                                      Text(
                                          "${DateFormat.yMMMMd().add_jm().format(flight.segments[j].departure.at)} - ${DateFormat.yMMMMd().add_jm().format(flight.segments[j].departure.at)}"),
                                      Text(
                                          "Duration: ${flight.segments[j].duration.toDuration().format()}"),
                                      Text(
                                          "Aircraft: ${flight.segments[j].aircraft.code.toPlaneName()}"),
                                      Container(height: 10),
                                      if (j < flight.segments.length - 1) ...[
                                        Text(
                                            "Layover in ${flight.segments[j + 1].departure.iataCode}"),
                                        Text(
                                            "Duration: ${flight.segments[j + 1].departure.at.difference(flight.segments[j].arrival.at).format()}"),
                                        Container(height: 10),
                                      ]
                                    ]
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Close"),
                                  )
                                ],
                              ),
                            );
                          },
                        ))
                      ]))
              .toList(),
        ),
      ],
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

    final Set<String> airlineCodes = {};
    for (var flight in flights) {
      for (var segment in flight.segments) {
        airlineCodes.add(segment.airlineOperating);
      }
    }

    final airlines = airlineCodes
        .map((code) => Airline.fromCode(code)?.name ?? code)
        .toList();
    airlines.sort((a, b) => a.compareTo(b));

    final popup = CheckboxPopup(
      options: airlines,
      selected: _selectedAirlines,
      onSelected: (List<String> newSelected) {
        setState(() {
          _selectedAirlines = newSelected;
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
    });
  }
}
