import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/new_trip_popup.dart';
import 'package:tripsitter/components/payment.dart';
import 'package:tripsitter/helpers/locators.dart';
import 'package:tripsitter/pages/login.dart';
import 'package:tripsitter/pages/update_profile.dart';

//TODO: pull and populate user info. have fallbacks for photo
class TripInfo extends StatefulWidget {
  final Trip trip;
  final Color col;

  TripInfo({
    required this.trip,
    required this.col,
  });

  @override
  State<TripInfo> createState() => _TripInfoState();
}

class _TripInfoState extends State<TripInfo> {
  @override
  Widget build(BuildContext context) {
    String name = widget.trip.name;
    String city = widget.trip.destination.name;
    String country = widget.trip.destination.country;
    String start = DateFormat.MMMd().format(widget.trip.startDate).toString();
    String end = DateFormat.MMMd().format(widget.trip.endDate).toString();
    String price = widget.trip.totalPrice.toString();
    return ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, "/trip/${widget.trip.id}");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.col,
          textStyle: TextStyle(color: Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  name,
                  style: TextStyle(color: Colors.black),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Colors.black,
                    ),
                    Text(
                      city + ', ' + country,
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: Colors.black,
                    ),
                    Text(
                      start,
                      style: TextStyle(color: Colors.black),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                    ),
                    Text(
                      end,
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                )
              ],
            ),
            Center(
              child: Text(
                price,
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ));
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? image = null;
  @override
  Widget build(BuildContext context) {
    UserProfile? profile = Provider.of<UserProfile?>(context);
    if (profile == null) {
      return UpdateProfile();
    }
    if (image == null && profile.hasPhoto) {
      FirebaseStorage.instance
          .ref('pictures/${profile.id}')
          .getDownloadURL()
          .then((a) {
        if (mounted) setState(() => image = a);
      });
    }
    // print(profile.id);
    // FirebaseFirestore.instance
    //     .collection('trips')
    //     .where('uids', arrayContains: profile.id)
    //     .get()
    //     .then((s) {
    //       s.docs.map(((doc) => Trip.fromFirestore(doc)));
    //     });
    return MultiProvider(
      providers: [
        StreamProvider.value(
            value: Trip.getTripsByProfile(profile.id),
            initialData: List<Trip>.empty(growable: true),
            catchError: (_, err) {
              print(err);
              return List<Trip>.empty(growable: true);
            }
          )
      ],
      child: Scaffold(
        appBar: AppBar(
          //contains the logo and trip sitter name
          title: Text('This Is the Profile Page'),
        ),
        //contains two columns to contain the user info in one and the trip info in the other

        body: Center(
          child: Row(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width * .55,
                  child:

                      //profile info
                      Column(
                    children: [
                      Row(
                        //profile part
                        children: [
                          Container(
                            //width: MediaQuery.of(context).size.width*.45 ,
                            child: Column(
                              //the icon and change button
                              children: [
                                CircleAvatar(
                                    backgroundImage:
                                        (profile.hasPhoto && image != null)
                                            ? NetworkImage(image!)
                                            : null,
                                    child: !(profile.hasPhoto && image != null)
                                        ? Icon(Icons.person)
                                        : null),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, "/profile");
                                    },
                                    child: Text("Edit Profile"))
                              ],
                            ),
                          ),
                          Container(
                            //width: MediaQuery.of(context).size.width*.55 ,
                            child: Column(
                              children: [
                                Text(profile.name),
                                Text(
                                    "Tripping since ${DateFormat.yMMM().format(profile.joinDate)}"),
                                Text("Number of trips: ${profile.numberTrips}"),
                              ],
                            ),
                          )
                        ],
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/new");
                          },
                          child: Text("Create New Trip"))
                      //button and possible picture/video
                    ],
                  )),
              //the trip info
              Container(
                  width: MediaQuery.of(context).size.width * .45,
                  child: Center(
                    child: Column(
                      children: [
                        Text("My Trips"),
                        Center(
                          child: Row(
                            children: [
                              Text("Upcoming"),
                              Icon(Icons.compare_arrows),
                              Text("Past")
                            ],
                          ),
                        ),
                        Builder(builder: (context) {
                          List<Trip> trips = Provider.of<List<Trip>>(context);
                          return Expanded(
                            child: ListView.builder(
                                itemCount: trips.length,
                                itemBuilder: (BuildContext context, int index) {
                                  // Generate a widget for each item in the list
                                  return TripInfo(
                                      trip: trips[index],
                                      col: Color.fromARGB(255, 148, 148, 148));
                                }),
                          );
                        }),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
