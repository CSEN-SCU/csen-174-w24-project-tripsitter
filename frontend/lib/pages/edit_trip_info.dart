import 'dart:async';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/classes/city.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/helpers/data.dart';

class EditTripInfo extends StatefulWidget {
  final Trip trip;
  const EditTripInfo(this.trip, {super.key});

  @override
  State<EditTripInfo> createState() => _EditTripInfoState();
}

class _EditTripInfoState extends State<EditTripInfo> {

  Trip get trip => widget.trip;


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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[300],
                border: InputBorder.none,
                labelText: 'Trip Name',
              ),
              controller: nameController,
              onChanged: (str) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 200), () {
                  debugPrint('Name changed to: $str');
                  trip.updateName(str);
                });
                
              },
            ),
          ),
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
                  labelText: 'Destination',
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
              },
            ),
          ),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                color: Colors.grey[300],
                height: 60,
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
                                  firstDate: trip.startDate.isAfter(DateTime.now())
                                      ? DateTime.now()
                                      : trip.startDate,
                                  lastDate: trip.endDate)
                              .then((date) {
                            if (date != null) {
                              trip.updateStartDate(date).then((value) {
                                setState(() {
                                });
                              });
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
                    const Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      color: Colors.black,
                      size: 36,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
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
                              trip.updateEndDate(date).then((value) {
                                                setState(() {
                                                });
                                              });
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
                ),
              )),
          
        ],
      ),
    );
  }
}