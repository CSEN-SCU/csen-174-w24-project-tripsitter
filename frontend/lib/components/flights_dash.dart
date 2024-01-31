// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tripsitter/classes/flights.dart';

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
  String _selectedStops = 'Any number of stops';
  List<String> _selectedAirlines = [];
  final GlobalKey _stopsButtonKey = GlobalKey();
  final GlobalKey _airlinesButtonKey = GlobalKey();
  final GlobalKey _bagsButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Select Flights'),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pushNamed(context, "/trip/1234");
            },
          ),
        ),
        body: Padding(
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
              ),
              SizedBox(height: 16.0),
              Wrap(
                spacing: 10,
                children: <Widget>[
                  FilterButton(
                    text: 'Stops',
                    globalKey:
                        _stopsButtonKey, // Pass the key to the FilterButton
                    onPressed: () =>
                        _showStopsPopup(_stopsButtonKey.currentContext),
                  ),
                  FilterButton(
                    text: 'Airlines',
                    globalKey: _airlinesButtonKey,
                    onPressed: () =>
                        _showAirlinesPopup(_airlinesButtonKey.currentContext),
                    //_showAirlinesPopup(context),
                  ),
                  FilterButton(
                    text: 'Bags',
                    globalKey: _bagsButtonKey,
                    onPressed: () {
                      // Handle Bags button press
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
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

    List<String> airlines = [
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

    await showMenu<String>(
      context: context,
      position: position,
      items: airlines.map((String airline) {
        return CheckedPopupMenuItem<String>(
          value: airline,
          checked: _selectedAirlines.contains(airline),
          child: Text(airline),
        );
      }).toList(), // Don't forget to convert the Iterable returned by map to a List
    ).then((String? selectedAirline) {
      if (selectedAirline != null) {
        setState(() {
          if (_selectedAirlines.contains(selectedAirline)) {
            _selectedAirlines.remove(selectedAirline);
          } else {
            _selectedAirlines.add(selectedAirline);
          }
        });
      }
    });
  }

  // void _showAirlinesPopup(BuildContext context) {
  //   List<String> airlines = [
  //     'Alaska',
  //     'American',
  //     'Breeze',
  //     'China Eastern',
  //     'Condor',
  //     'Delta',
  //     'Emirates',
  //     'Frontier',
  //     'JetBlue',
  //     'Qatar Airways',
  //     'Scandinavian Airlines',
  //     'Southern Airways Express',
  //     'Southwest',
  //     'Spirit',
  //     'United'
  //   ];
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Select Airlines'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: airlines.map((String airline) {
  //               return CheckboxListTile(
  //                 title: Text(airline),
  //                 value: _selectedAirlines.contains(airline),
  //                 onChanged: (bool? value) {
  //                   setState(() {
  //                     if (value ?? false) {
  //                       _selectedAirlines.add(airline);
  //                     } else {
  //                       _selectedAirlines.remove(airline);
  //                     }
  //                   });
  //                   // Do not pop the dialog on change.
  //                 },
  //               );
  //             }).toList(),
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Done'),
  //             onPressed: () {
  //               Navigator.of(context)
  //                   .pop(); // Close the dialog when the user is done with the selection
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
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
