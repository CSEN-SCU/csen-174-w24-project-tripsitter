import 'package:flutter/material.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';

class TripSummary extends StatelessWidget {
  final Trip trip;
  final String uid;
  final List<UserProfile> profiles;
  const TripSummary({required this.trip, required this.uid, required this.profiles, super.key});

  bool get split => trip.usingSplitPayments;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Trip: ${trip.name}"),
          if((split ? trip.flights.where((f) => f.members.contains(uid)) : trip.flights).isNotEmpty)
            ...[
              Text("Flights: \$${split ? trip.userFlightsPrice(uid) : trip.flightsPrice}${split ? "" : " total"}"),
              for(var flight in (split ? trip.flights.where((f) => f.members.contains(uid)) : trip.flights))
                ...[
                  Text("${flight.departureAirport} -> ${flight.arrivalAirport} (${split ? (flight.userPrice(uid) == null ? "Unknown price" : "\$${flight.userPrice(uid)}") : (flight.price == null ? "Unknown price" : "\$${flight.price} total")})"),
                  if(flight.pnr != null)
                    Text("Confirmation number: ${flight.pnr}"),
                  if(!split)
                    Text(flight.members.map((e) => profiles.firstWhere((profile) => profile.id == e).name).join(", ")),
                ],
                Container(height: 10)
            ],
          if((split ? trip.hotels.where((h) => h.members.contains(uid)) : trip.hotels).isNotEmpty)
            ...[
              Text("Hotels: \$${split ? trip.userHotelsPrice(uid) : trip.hotelsPrice}${split ? "" : " total"}"),
              for(var hotel in (split ? trip.hotels.where((h) => h.members.contains(uid)) : trip.hotels))
                ...[
                  Text("${hotel.name} (${split ? (hotel.userPrice(uid) == null ? "Unknown price" : "\$${hotel.userPrice(uid)}") :(hotel.price == null ? "Unknown price" : "\$${hotel.price} total")})"),
                  if(hotel.pnr != null)
                    Text("Confirmation Number: ${hotel.pnr}"),
                  if(!split)
                    Text(hotel.members.map((e) => profiles.firstWhere((profile) => profile.id == e).name).join(", ")),
                ],
              Container(height: 10)
            ],
          if((split ? trip.rentalCars.where((r) => r.members.contains(uid)) : trip.rentalCars).isNotEmpty)
            ...[
              Text("Rental Cars: \$${split ? trip.userRentalCarsPrice(uid) : trip.rentalCarsPrice}${split ? "" : " total"}"),
              for(var rentalCar in (split ? trip.rentalCars.where((r) => r.members.contains(uid)) : trip.rentalCars))
                ...[
                  Text("${rentalCar.name} (${split ? ("\$${rentalCar.userPrice(uid)}") : ("\$${rentalCar.price} total")})"),
                  if(!split)
                    Text(rentalCar.members.map((e) => profiles.firstWhere((profile) => profile.id == e).name).join(", ")),
                ],
              Container(height: 10)
            ],
          if((split ? trip.activities.where((a) => a.participants.contains(uid)) : trip.activities).isNotEmpty)
            ...[
              Text("Activities: \$${split ? trip.userActivitiesPrice(uid) : trip.activitiesPrice} total"),
              for(var activity in (split ? trip.activities.where((a) => a.participants.contains(uid)) : trip.activities))
                ...[
                  Text("${activity.event.name} (${split ? (activity.userPrice(uid) == null ? "Unknown price" : "\$${activity.userPrice(uid)}") : (activity.price == null ? "Unknown price" : "\$${activity.price} total")})"),
                  if(!split)
                    Text(activity.participants.map((e) => profiles.firstWhere((profile) => profile.id == e).name).join(", ")),
                ],
              Container(height: 10)
            ],
      ],
    );
  }
}