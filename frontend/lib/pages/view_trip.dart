// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/cars/select_cars.dart';
import 'package:tripsitter/components/checkout/trip_summary.dart';
import 'package:tripsitter/components/comments.dart';
import 'package:tripsitter/components/hotels/select_hotels.dart';
import 'package:tripsitter/components/map.dart';
import 'package:tripsitter/components/mobile_wrapper.dart';
import 'package:tripsitter/components/events/select_events.dart';
import 'package:tripsitter/components/flights/select_flight.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/components/navbar.dart';
import 'package:tripsitter/components/restaurants/select_restaurants.dart';
import 'package:tripsitter/components/trip_dash.dart';
import 'package:tripsitter/components/trip_side_column.dart';
import 'package:tripsitter/components/checkout/checkout.dart';
import 'package:tripsitter/helpers/styles.dart';
import 'package:tripsitter/pages/edit_trip_info.dart';
import 'package:tripsitter/pages/login.dart';

class ViewTrip extends StatelessWidget {
  final String tripId;
  const ViewTrip(this.tripId, {super.key});

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);
    if(user == null) {
      return const LoginPage();
    }
    bool isMobile = Provider.of<bool>(context);
    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: Trip.getTripById(tripId),
          initialData: null,
        ),
      ],
      child: Builder(
        builder: (context) {
          Trip? trip = Provider.of<Trip?>(context);
          if(trip == null) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return MultiProvider(
            providers: [
              FutureProvider.value(
                value: UserProfile.getTripProfiles(trip.uids),
                initialData: List<UserProfile>.empty(growable: true),
              )
            ],
            child: Scaffold(
              appBar: const TripSitterNavbar(),
              body: ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: Container(
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      if(isMobile) {
                        List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
                        return ListView(
                          children: [
                            Text(trip.name, 
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 40,
                                // decoration: TextDecoration.underline,
                                decorationColor: Colors.black,
                                decorationThickness: 1.2,
                              )
                            ),
                            Text("${DateFormat('MMM d, yyyy').format(trip.startDate)} → ${DateFormat('MMM d, yyyy').format(trip.endDate)}", style: sectionHeaderStyle.copyWith(fontSize: 15)),
                            Text("${trip.destination.name}, ${trip.destination.country}", style: sectionHeaderStyle.copyWith(fontSize: 15)),
                            if(!trip.frozen)
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text("Edit Trip Info"),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(trip: trip, profiles: profiles, title: "Edit Trip Info", child: EditTripInfo(trip)))),
                              ),
                            ListTile(
                              leading: const Icon(Icons.people),
                              title: const Text("Manage Participants"),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(trip: trip, profiles: profiles, title: "Manage Participants", child: TripSideColumn(trip)))),
                            ),
                            ListTile(
                              leading: const Icon(Icons.message),
                              title: const Text("Discussion"),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(trip: trip, profiles: profiles, title: "Discussion", child: CommentsSection(trip: trip, profiles: profiles, user: user)))),
                            ),
                            if(!trip.frozen)
                              ...[
                                ListTile(
                                  leading: const Icon(Icons.flight_takeoff_rounded),
                                  title: const Text("Flights"),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(trip: trip, profiles: profiles, title: "Select Flights", child: SelectFlight(trip, profiles)))),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.hotel),
                                  title: const Text("Hotels"),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(trip: trip, profiles: profiles, title: "Select Hotels", child: SelectHotels(trip, profiles)))),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.directions_car),
                                  title: const Text("Rental Cars"),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(title: "Select Rental Cars", child: SelectCars(trip, profiles)))),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.stadium),
                                  title: const Text("Activities"),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(title: "Select Activites", child: SelectEvents(trip, profiles)))),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.restaurant),
                                  title: const Text("Restaurants"),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(title: "Select Restaurants", child: SelectRestaurants(trip, profiles)))),
                                ),
                              ],
                              ListTile(
                                leading: const Icon(Icons.map),
                                title: const Text("Trip Map"),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(title: "Trip Map", child: TripsitterMap<int>(
                                  items: [],
                                  createWidget: (dynamic item) {
                                    return Container();
                                  },
                                  trip: trip,
                                  getLat: (r) => 0.0, 
                                  getLon: (r) => 0.0, 
                                  isSelected: (r) => false, 
                                  extras: const [
                                    MarkerType.activity,
                                    MarkerType.hotel,
                                    MarkerType.restaurant,
                                    MarkerType.airport,
                                  ]
                                )))),
                              ),
                            if(trip.frozen)
                              ListTile(
                                leading: const Icon(Icons.list),
                                title: const Text("Trip Itinerary"),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(trip: trip, profiles: profiles, title: "Trip Itinerary", child: ListView(
                                  children: [
                                    TripSummary(trip: trip, uid: user.uid, profiles: profiles, showSplit: false, showBooking: true),
                                  ],
                                )))),
                              ),
                            if(!trip.frozen)
                              CheckboxListTile(
                                value: trip.usingSplitPayments,
                                title: const Text("Split Payments"), 
                                onChanged: (bool? value) {
                                  trip.toggleSplitPayments();
                                },
                              ),
                            if((trip.usingSplitPayments ? trip.paymentsComplete[user.uid] != true : !trip.isConfirmed))
                              ListTile(
                                leading: const Icon(Icons.credit_card),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage(trip: trip, profiles: profiles)));
                                }, 
                                title: const Text("Checkout"),
                              ),
                            if((!trip.isConfirmed && trip.usingSplitPayments && trip.paymentsComplete[user.uid] == true))
                              const Text("Awaiting payment from all members", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            if(trip.isConfirmed)
                              const Text("Trip is confirmed", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Container(width: 10),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(context: context, builder: (context) => 
                                    AlertDialog(
                                      title: const Text("Delete Trip"),
                                      content: const Text("Are you sure you want to delete this trip?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          }, 
                                          child: const Text("Cancel")
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await trip.delete();
                                            Navigator.pop(context);
                                            Navigator.pushNamed(context, "/");
                                          }, 
                                          child: const Text("Delete")
                                        )
                                      ]
                                  ));
                                }, 
                                icon: const Icon(Icons.delete), 
                                label: const Text("Delete Trip")
                              ),
                            ),
                            Container(height: 30)
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
                              return SizedBox(
                                width: constraints.maxWidth * 0.7,
                                child: trip.frozen ? Container(color: const Color.fromARGB(255, 255, 255, 255), padding: const EdgeInsets.all(8), child: ListView(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: TripSummary(
                                        trip: trip, 
                                        uid: Provider.of<User?>(context)?.uid ?? "", 
                                        profiles: profiles,
                                        showBooking: true,
                                        showSplit: !trip.isConfirmed,
                                      ),
                                    ),
                                  ],
                                )) : TripDashBoard(trip),
                              );
                            }
                          ),
                          Container(
                            color: const Color.fromARGB(255, 239, 239, 239),
                            width: constraints.maxWidth * 0.3,
                            child: TripSideColumn(trip)
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
