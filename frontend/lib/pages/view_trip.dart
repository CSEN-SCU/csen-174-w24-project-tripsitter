import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/cars/select_cars.dart';
import 'package:tripsitter/components/hotels/select_hotels.dart';
import 'package:tripsitter/components/mobile_wrapper.dart';
import 'package:tripsitter/components/events/select_events.dart';
import 'package:tripsitter/components/flights/select_flight.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/components/navbar.dart';
import 'package:tripsitter/components/trip_dash.dart';
import 'package:tripsitter/components/trip_side_column.dart';
import 'package:tripsitter/components/checkout/checkout.dart';
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
              StreamProvider.value(
                value: UserProfile.getTripProfiles(trip.uids),
                initialData: List<UserProfile>.empty(growable: true),
              )
            ],
            child: Scaffold(
              appBar: const TripSitterNavbar(),
              body: ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: Container(
                  color: const Color.fromRGBO(232, 232, 232, 1),
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      if(isMobile) {
                        List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
                        return Column(
                          children: [
                            Text("${trip.name}", 
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 40,
                                // decoration: TextDecoration.underline,
                                decorationColor: Colors.black,
                                decorationThickness: 1.2,
                              )
                            ),
                            ListTile(
                              leading: Icon(Icons.people),
                              title: Text("Manage Participants"),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(trip: trip, profiles: profiles, title: "Manage Participants", child: TripSideColumn(trip)))),
                            ),
                            ListTile(
                              leading: const Icon(Icons.flight_takeoff_rounded),
                              title: Text("Flights"),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(trip: trip, profiles: profiles, title: "Select Flights", child: SelectFlight(trip, profiles)))),
                            ),
                            ListTile(
                              leading: const Icon(Icons.hotel),
                              title: Text("Hotels"),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(trip: trip, profiles: profiles, title: "Select Hotels", child: SelectHotels(trip, profiles)))),
                            ),
                            ListTile(
                              leading: const Icon(Icons.directions_car),
                              title: Text("Rental Cars"),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(title: "Select Rental Cars", child: SelectCars(trip, profiles)))),
                            ),
                            ListTile(
                              leading: const Icon(Icons.stadium),
                              title: Text("Activities"),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MobileWrapper(title: "Select Activites", child: SelectEvents(trip, profiles)))),
                            ),
                            CheckboxListTile(
                              value: trip.usingSplitPayments,
                              title: Text("Split payments"), 
                              onChanged: (bool? value) {
                                trip.toggleSplitPayments();
                              },
                            ),
                            if((trip.usingSplitPayments ? trip.paymentsComplete[user.uid] != true : !trip.isConfirmed))
                              ListTile(
                                leading: Icon(Icons.credit_card),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage(trip: trip, profiles: profiles)));
                                }, 
                                title: Text("Checkout"),
                              ),
                            if((!trip.isConfirmed && trip.usingSplitPayments && trip.paymentsComplete[user.uid] == true))
                              Text("Awaiting payment from all members", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            if(trip.isConfirmed)
                              Text("Trip is confirmed", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: TripDashBoard(),
                            width: constraints.maxWidth * 0.7,
                          ),
                          Container(
                            color: Color.fromARGB(255, 239, 239, 239),
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
