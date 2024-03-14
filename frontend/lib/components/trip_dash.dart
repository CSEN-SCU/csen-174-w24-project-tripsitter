// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/city.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/trip_center_console.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:tripsitter/helpers/data.dart';

class TripDashBoard extends StatefulWidget {
  final Trip trip;
  const TripDashBoard(this.trip,{super.key});

  @override
  State<TripDashBoard> createState() => _TripDashBoardState();
}

class _TripDashBoardState extends State<TripDashBoard> {
  late TextEditingController nameController;
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.trip.name);
    loadCities();
  }

  List<City> cities = [];

  void loadCities() async {
    cities = await getCities(context);
    if (mounted) {
      var result = await DefaultAssetBundle.of(context).loadString(
        "assets/worldcities.csv",
      );
      List<List<dynamic>> list =
          const CsvToListConverter().convert(result, eol: "\n");
      list.removeAt(0);
      if (!mounted) {
        return;
      }
      setState(() {});
    }
  }

  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    Color accentColor = Color.fromRGBO(138, 138, 138, 1);
    Trip? trip = Provider.of<Trip?>(context);
    if (trip == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
        color: Color.fromARGB(255, 255, 255, 255),
        width: 75.0,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Container(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  width: constraints.maxWidth,
                  height: constraints.maxHeight * 0.1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 20.0),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: nameController,
                          onChanged: (str) {
                            if (_debounce?.isActive ?? false) _debounce?.cancel();
                            _debounce = Timer(const Duration(milliseconds: 200), () {
                              debugPrint('Name changed to: $str');
                              trip.updateName(str);
                            });
                            
                          },
                          style: GoogleFonts.kadwa(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Padding(
                        padding: EdgeInsets.only(top: 11.0),
                        child: Icon(
                          Icons.pin_drop_outlined,
                          size: 26,
                          color: accentColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(context: context, builder:(context) {
                              return AlertDialog(
                                title: Text("Change Destination"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Enter a new destination"),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Autocomplete<City>(
                                        fieldViewBuilder: (context, textEditingController, focusNode,
                                                onFieldSubmitted) =>
                                            TextFormField(
                                          controller: textEditingController,
                                          focusNode: focusNode,
                                          onFieldSubmitted: (_) {},
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.grey[300],
                                            border: InputBorder.none,
                                            labelText: 'Hometown',
                                          ),
                                        ),
                                        initialValue: TextEditingValue(
                                            text: "${trip.destination.name}, ${trip.destination.country}"),
                                        displayStringForOption: (option) =>
                                            "${option.name}, ${option.country}",
                                        optionsBuilder: (TextEditingValue value) {
                                          if (value.text == '') {
                                            return const Iterable<City>.empty();
                                          }
                                          return cities.where((t) {
                                            return t.name
                                                .toLowerCase()
                                                .contains(value.text.toLowerCase());
                                          });
                                        },
                                        onSelected: (selected) async {
                                          await trip.updateDestination(selected);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Cancel"),
                                  ),
                                ],
                              );
                            });
                          },
                          child: Text(
                            "${trip.destination.name}, ${trip.destination.country}",
                            style: TextStyle(
                              fontSize: 24,
                              fontStyle: FontStyle.italic,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 80.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(25.0),
                                  ),
                                  color: HexColor("#DFE8FF"),
                                ),
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    SizedBox(width: 30.0),
                                    Icon(
                                      Icons.calendar_month_outlined,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          showDatePicker(
                                                  context: context,
                                                  initialDate: trip.startDate,
                                                  firstDate: DateTime.now(),
                                                  lastDate: trip.endDate)
                                              .then((date) {
                                            if (date != null) {
                                              trip.updateStartDate(date);
                                            }
                                          });
                                        },
                                        child: Text(
                                          DateFormat('MMM d')
                                              .format(trip.startDate),
                                          style: TextStyle(
                                              color: Colors.black, fontSize: 15),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_double_arrow_right_rounded,
                                      color: Colors.black,
                                      size: 36,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          showDatePicker(
                                                  context: context,
                                                  initialDate: trip.endDate,
                                                  firstDate: trip.startDate,
                                                  lastDate: DateTime(2101))
                                              .then((date) {
                                            if (date != null) {
                                              trip.updateEndDate(date);
                                            }
                                          });
                                        },
                                        child: Text(
                                          DateFormat('MMM d')
                                              .format(trip.endDate),
                                          style: TextStyle(
                                              color: Colors.black, fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: TripCenterConsole(
                    trip,
                    constraints.maxWidth,
                    constraints.maxHeight * 0.9,
                  )
                ),
              ],
            );
          },
        ));
  }
}
