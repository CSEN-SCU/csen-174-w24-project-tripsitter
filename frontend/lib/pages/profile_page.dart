import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  name,
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Colors.black,
                    ),
                    SizedBox(width: 5),
                    Text(
                      city + ', ' + country,
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: Colors.black,
                    ),
                    SizedBox(width: 5),
                    Text(
                      start,
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward,
                      size: 15,
                      color: Colors.black,
                    ),
                    SizedBox(width: 5),
                    Text(
                      end,
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
            SizedBox(width: 300),
            Center(
              child: Text(
                '\$' + price,
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
            })
      ],
      child: Scaffold(
        appBar: AppBar(
          //contains the logo and trip sitter name
          title: Text('My Profile'),
          backgroundColor: Color.fromARGB(255, 238, 238, 238),
        ),
        //contains two columns to contain the user info in one and the trip info in the other
        body: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Center(
            child: Row(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * .55,
                    child:
                        //profile info
                        Column(
                      children: [
                        Text("About Me", style: TextStyle(fontSize: 20)),
                        Row(
                          //profile part
                          children: [
                            SizedBox(width: 25),
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
                                      child:
                                          !(profile.hasPhoto && image != null)
                                              ? Icon(Icons.person)
                                              : null),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, "/profile");
                                      },
                                      child: Text("Edit Profile"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromARGB(255, 238, 238, 238),
                                        foregroundColor: Colors.black,
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(width: 111),
                            Container(
                              //width: MediaQuery.of(context).size.width*.55 ,
                              child: Column(
                                children: [
                                  Text(profile.name),
                                  Text(
                                      "Tripping since ${DateFormat.yMMM().format(profile.joinDate)}"),
                                  Text(
                                      "Number of Trips: ${profile.numberTrips}"),
                                ],
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/new");
                              },
                              child: Text("Create New Trip"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 125, 175, 220),
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ],
                        ),

                        //button and possible picture/video
                      ],
                    )),
                //the trip info
                Container(
                    width: MediaQuery.of(context).size.width * .45,
                    child: Center(
                      child: Column(
                        children: [
                          Text("My Trips", style: TextStyle(fontSize: 20)),
                          Center(
                            child: Row(
                              children: [
                                Text("Upcoming"),
                                SizedBox(width: 10),
                                Icon(Icons.compare_arrows),
                                SizedBox(width: 10),
                                Text("Past")
                              ],
                            ),
                          ),
                          Builder(builder: (context) {
                            List<Trip> trips = Provider.of<List<Trip>>(context);
                            return Expanded(
                              child: ListView.builder(
                                  itemCount: trips.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    // Generate a widget for each item in the list
                                    return TripInfo(
                                        trip: trips[index],
                                        col:
                                            Color.fromARGB(255, 148, 148, 148));
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
      ),
    );
  }
}
