import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/pages/update_profile.dart';

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
          textStyle: const TextStyle(color: Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_pin,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$city, $country',
                      style: const TextStyle(color: Colors.black),
                    )
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      start,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.arrow_forward,
                      size: 15,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      end,
                      style: const TextStyle(color: Colors.black),
                    )
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
            const SizedBox(width: 300),
            Center(
              child: Text(
                '\$$price',
                style: const TextStyle(color: Colors.black),
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
  String? image;
  @override
  Widget build(BuildContext context) {
    UserProfile? profile = Provider.of<UserProfile?>(context);
    if (profile == null) {
      return const UpdateProfile();
    }
    if (image == null && profile.hasPhoto) {
      FirebaseStorage.instance
          .ref('pictures/${profile.id}')
          .getDownloadURL()
          .then((a) {
        if (mounted) setState(() => image = a);
      });
    }
    // debugPrint(profile.id);
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
              debugPrint(err.toString());
              return List<Trip>.empty(growable: true);
            })
      ],
      child: Scaffold(
        appBar: AppBar(
          //contains the logo and trip sitter name
          title: const Text('My Profile'),
          backgroundColor: const Color.fromARGB(255, 238, 238, 238),
        ),
        //contains two columns to contain the user info in one and the trip info in the other
        body: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Center(
            child: Row(
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * .55,
                    child:
                        //profile info
                        Column(
                      children: [
                        const Text("About Me", style: TextStyle(fontSize: 20)),
                        Row(
                          //profile part
                          children: [
                            const SizedBox(width: 25),
                            Column(
                              //the icon and change button
                              children: [
                                CircleAvatar(
                                    backgroundImage:
                                        (profile.hasPhoto && image != null)
                                            ? NetworkImage(image!)
                                            : null,
                                    child:
                                        !(profile.hasPhoto && image != null)
                                            ? const Icon(Icons.person)
                                            : null),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, "/profile");
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 238, 238, 238),
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text("Edit Profile")),
                              ],
                            ),
                            const SizedBox(width: 111),
                            Column(
                              children: [
                                Text(profile.name),
                                Text(
                                    "Tripping since ${DateFormat.yMMM().format(profile.joinDate)}"),
                                Text(
                                    "Number of Trips: ${profile.numberTrips}"),
                              ],
                            )
                          ],
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/new");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 125, 175, 220),
                                foregroundColor: Colors.black,
                              ),
                              child: const Text("Create New Trip"),
                            ),
                          ],
                        ),

                        //button and possible picture/video
                      ],
                    )),
                //the trip info
                SizedBox(
                    width: MediaQuery.of(context).size.width * .45,
                    child: Center(
                      child: Column(
                        children: [
                          const Text("My Trips", style: TextStyle(fontSize: 20)),
                          const Center(
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
                                            const Color.fromARGB(255, 148, 148, 148));
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
