import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/city.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/navbar.dart';
import 'package:tripsitter/helpers/data.dart';
import 'package:tripsitter/pages/login.dart';

class CreateTrip extends StatefulWidget {
  const CreateTrip({super.key});

  @override
  State<CreateTrip> createState() => _CreateTripState();
}

class _CreateTripState extends State<CreateTrip> {
  TextEditingController addressController = TextEditingController();
  City? selectedCity;

  DateTime? startDate;
  DateTime? endDate;

  List<City> cities = [];

  @override
  void initState() {
    super.initState();
    loadCities();
  }

  void loadCities() async {
    cities = await getCities(context);
    setState(() {});
  }

  Future<void> createTrip(String uid) async {
    if (selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a city'),
        ),
      );
      return;
    }
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a start and end date'),
        ),
      );
      return;
    }
    if (startDate!.isAfter(endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start date must be before end date'),
        ),
      );
      return;
    }
    DocumentReference doc = FirebaseFirestore.instance.collection('trips').doc();
    Trip newTrip = Trip(
      comments: List.empty(growable: true),
      id: doc.id, 
      uids: [uid], 
      paymentsComplete: {uid: false},
      frozen: false,
      usingSplitPayments: false,
      name: "My Trip to ${selectedCity!.name}",
      startDate: startDate!, 
      endDate: endDate!, 
      destination: selectedCity!, 
      isConfirmed: false,
      flights: List.empty(growable: true), 
      hotels: List.empty(growable: true), 
      rentalCars: List.empty(growable: true), 
      activities: List.empty(growable: true)
    );
    await newTrip.save();
    // ignore: use_build_context_synchronously
    UserProfile? profile = Provider.of<UserProfile?>(context, listen: false); 
    profile?.addTrip();
    await profile?.save();
    // ignore: use_build_context_synchronously
    Navigator.pushNamed(context, "/trip/${newTrip.id}");
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);
    if(user == null) {
      return const LoginPage();
    }
    return Scaffold(
      appBar: const TripSitterNavbar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                Center(child: Text('Let\'s get started', style: Theme.of(context).textTheme.displayMedium)),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Tell me some basic details about your dream trip"),
                ),
                // address input field
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Autocomplete<City>(
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) => TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onFieldSubmitted: (_) {},
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: InputBorder.none,
                        labelText: 'Location',
                      ),
                    ),
                    displayStringForOption: (option) => "${option.name}, ${option.country}",
                    optionsBuilder: (TextEditingValue value) {
                      if(value.text == '') {
                        return const Iterable<City>.empty();
                      }
                      return cities.where((t){
                        return t.name.toLowerCase().contains(value.text.toLowerCase());
                      });
                    },
                    onSelected: (selected) {
                      selectedCity = selected;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onTap: () async {
                      DateTime? d = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2024, 1, 1),
                        lastDate: endDate ?? DateTime(2100),
                      );
                      if (d != null) {
                        setState(() => startDate = d);
                      }
                    },
                    readOnly: true,
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: startDate == null
                          ? ''
                          : DateFormat(DateFormat.YEAR_MONTH_DAY).format(startDate!),
                      ),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: InputBorder.none,
                      labelText: 'Start Date',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onTap: () async {
                      DateTime? d = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? startDate ?? DateTime.now(),
                        firstDate: startDate ?? DateTime(2024, 1, 1),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) {
                        setState(() => endDate = d);
                      }
                    },
                    readOnly: true,
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: endDate == null
                          ? ''
                          : DateFormat(DateFormat.YEAR_MONTH_DAY).format(endDate!),
                      ),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: InputBorder.none,
                      labelText: 'End Date',
                    ),
                  ),
                ),
            
                Container(height: 50),
                ElevatedButton(
                  onPressed: () => createTrip(user.uid),
                  child: const Text('Create Trip'),
                ),
                // time input field
              ],
            ),
          ),
        ),
      ),
    );
  }
}