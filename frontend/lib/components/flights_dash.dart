// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/helpers/api.dart';

FlightsQuery query = FlightsQuery(
    origin: 'LAX',
    destination: 'SFO',
    departureDate: DateTime(2024, 6, 1),
    returnDate: DateTime(2024, 6, 5),
    adults: 1,
    travelClass: TravelClass.economy);

class FlightsDashBoard extends StatefulWidget {
  const FlightsDashBoard({super.key});

  @override
  _FlightsDashBoardState createState() => _FlightsDashBoardState();
}

class _FlightsDashBoardState extends State<FlightsDashBoard> {
  List<String> airlines = [
    'Select All',
    'Deselect All',
    'Alaska',
    'American',
    'Breeze',
    'China Eastern',
    'Condor',
    'Delta',
    'Emirates',
    'Frontier',
    'JetBlue',
    'Qatar Airways',
    'Scandinavian Airlines',
    'Southern Airways Express',
    'Southwest',
    'Spirit',
    'United'
  ];

  String _selectedStops = 'Any number of stops';
  List<String> _selectedAirlines = [];
  int numCarryOnBags = 0;
  int numCheckedBags = 0;
  final GlobalKey _stopsButtonKey = GlobalKey();
  final GlobalKey _airlinesButtonKey = GlobalKey();
  final GlobalKey _bagsButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black, // Default text color for body text
              displayColor: Colors.black, // Default text color for display text
            ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pushNamed(context, "/trip/1234");
                  },
                ),
                SizedBox(width: 8),
                Text(
                  'Select Flights',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Choose flights from JFK',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  _selectedStops,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle select return trip
                  },
                  child: Text('Select return trip'),
                  style: TextButton.styleFrom(
                      //primary: Colors.black, // Ensures the text color for buttons
                      ),
                ),
                SizedBox(height: 16.0),
                Wrap(
                  spacing: 10,
                  children: <Widget>[
                    FilterButton(
                      text: 'Stops',
                      globalKey: _stopsButtonKey,
                      onPressed: () =>
                          _showStopsPopup(_stopsButtonKey.currentContext),
                    ),
                    FilterButton(
                      text: 'Airlines',
                      globalKey: _airlinesButtonKey,
                      onPressed: () =>
                          _showAirlinesPopup(_airlinesButtonKey.currentContext),
                    ),
                    FilterButton(
                      text: 'Bags',
                      globalKey: _bagsButtonKey,
                      onPressed: () =>
                          _showBagsPopup(_bagsButtonKey.currentContext),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  _selectedStops,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStopsPopup(BuildContext? buttonContext) async {
    if (buttonContext == null) return;

    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(buttonContext).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero + Offset(0, button.size.height)),
        button.localToGlobal(Offset.zero) +
            Offset(button.size.width, button.size.height),
      ),
      Offset.zero & overlay.size,
    );

    final String? selectedStop = await showMenu<String>(
      context: context,
      position: position, // Use the updated position
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
            value: 'Any number of stops', child: Text('Any number of stops')),
        PopupMenuItem<String>(
            value: 'Nonstop only', child: Text('Nonstop only')),
        PopupMenuItem<String>(
            value: '1 stop or fewer', child: Text('1 stop or fewer')),
        PopupMenuItem<String>(
            value: '2 stops or fewer', child: Text('2 stops or fewer')),
      ],
    );

    // Handle the selected stop
    if (selectedStop != null) {
      setState(() {
        _selectedStops = selectedStop;
      });
    }
  }

  void _showAirlinesPopup(BuildContext? buttonContext) async {
    if (buttonContext == null) return;

    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(buttonContext).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero + Offset(0, button.size.height)),
        button.localToGlobal(Offset.zero) +
            Offset(button.size.width, button.size.height),
      ),
      Offset.zero & overlay.size,
    );

    await showMenu<String>(
      context: context,
      position: position,
      items: airlines.map((String airline) {
        if (airline == 'Select All' || airline == 'Deselect All') {
          return PopupMenuItem<String>(
            value: airline,
            child: Text(airline),
          );
        }
        return CheckedPopupMenuItem<String>(
          value: airline,
          checked: _selectedAirlines.contains(airline),
          child: Text(airline),
        );
      }).toList(),
    ).then((String? selectedAirline) {
      if (selectedAirline != null) {
        setState(() {
          if (selectedAirline == 'Select All') {
            _selectedAirlines = List.from(airlines)
              ..remove('Select All')
              ..remove('Deselect All');
          } else if (selectedAirline == 'Deselect All') {
            _selectedAirlines.clear();
          } else if (_selectedAirlines.contains(selectedAirline)) {
            _selectedAirlines.remove(selectedAirline);
          } else {
            _selectedAirlines.add(selectedAirline);
          }
        });
      }
    });
  }

  void _showBagsPopup(BuildContext? buttonContext) async {
    if (buttonContext == null) return;

    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(buttonContext).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero + Offset(0, button.size.height)),
        button.localToGlobal(Offset.zero) +
            Offset(button.size.width, button.size.height),
      ),
      Offset.zero & overlay.size,
    );

    await showMenu<void>(
      context: context,
      position: position,
      items: [
        PopupMenuItem<void>(
          enabled: false, // Disable interaction with this item
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('# Carry On Bags'),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (numCarryOnBags > 0) {
                            setState(() => numCarryOnBags--);
                          }
                        },
                      ),
                      Text('$numCarryOnBags'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() => numCarryOnBags++);
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('# Checked Bags'),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (numCheckedBags > 0) {
                            setState(() => numCheckedBags--);
                          }
                        },
                      ),
                      Text('$numCheckedBags'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() => numCheckedBags++);
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
      elevation: 8.0,
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed; // Define the onPressed parameter
  final GlobalKey globalKey;

  const FilterButton(
      {required this.text, required this.onPressed, required this.globalKey});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: globalKey, // Assign the globalKey to the ElevatedButton
      onPressed: onPressed, // Use the onPressed parameter here
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(text),
          Icon(Icons.arrow_drop_down),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
      ),
    );
  }
}
