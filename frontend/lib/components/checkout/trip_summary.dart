import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/checkout/activity_summary.dart';
import 'package:tripsitter/components/checkout/car_summary.dart';
import 'package:tripsitter/components/checkout/flight_summary.dart';
import 'package:tripsitter/components/checkout/hotel_summary.dart';
import 'package:tripsitter/helpers/styles.dart';

class TripSummary extends StatelessWidget {
  final Trip trip;
  final String uid;
  final List<UserProfile> profiles;
  final bool showSplit;
  final bool showBooking;
  const TripSummary({required this.trip, required this.uid, required this.profiles, this.showSplit = true, this.showBooking = false, super.key});

  bool get split => trip.usingSplitPayments && showSplit;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 650,
      ),
      child: MultiProvider(
        providers: [
          Provider.value(value: profiles),
          Provider.value(value: split),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trip.name, style: sectionHeaderStyle),
            Text("${DateFormat('MMM d, yyyy').format(trip.startDate)} → ${DateFormat('MMM d, yyyy').format(trip.endDate)}", style: sectionHeaderStyle.copyWith(fontSize: 15)),
            Text("${trip.destination.name}, ${trip.destination.country}", style: sectionHeaderStyle.copyWith(fontSize: 15)),
            Container(height: 20),
            if((split ? trip.flights.where((f) => f.members.contains(uid)) : trip.flights).isNotEmpty)
              ...[
                SummaryHeader("Flights: \$${split ? trip.userFlightsPrice(uid) : trip.flightsPrice}${split ? "" : " total"}", icon: Icons.flight_takeoff_rounded),
                for(var flight in (split ? trip.flights.where((f) => f.members.contains(uid)) : trip.flights))
                  FlightSummary(flight: flight, price: split ? flight.userPrice(uid) : flight.price),
                Container(height: 10)
              ],
            if((split ? trip.hotels.where((h) => h.members.contains(uid)) : trip.hotels).isNotEmpty)
              ...[
                SummaryHeader("Hotels: \$${split ? trip.userHotelsPrice(uid) : trip.hotelsPrice}${split ? "" : " total"}", icon: Icons.hotel_rounded),
                for(var hotel in (split ? trip.hotels.where((h) => h.members.contains(uid)) : trip.hotels))
                  HotelSummary(hotel: hotel, price: split ? hotel.userPrice(uid) : hotel.price),
                Container(height: 10)
              ],
            if((split ? trip.rentalCars.where((r) => r.members.contains(uid)) : trip.rentalCars).isNotEmpty)
              ...[
                SummaryHeader("Rental Cars: \$${split ? trip.userRentalCarsPrice(uid) : trip.rentalCarsPrice}${split ? "" : " total"}", icon: Icons.directions_car_rounded),
                for(var rentalCar in (split ? trip.rentalCars.where((r) => r.members.contains(uid)) : trip.rentalCars))
                  CarSummary(car: rentalCar, price: split ? rentalCar.userPrice(uid) : rentalCar.price, showBooking: showBooking),
                Container(height: 10)
              ],
            if((split ? trip.activities.where((a) => a.participants.contains(uid)) : trip.activities).isNotEmpty)
              ...[
                SummaryHeader("Activities: \$${split ? trip.userActivitiesPrice(uid) : trip.activitiesPrice} total", icon: Icons.stadium_rounded),
                for(var activity in (split ? trip.activities.where((a) => a.participants.contains(uid)) : trip.activities))
                  ActivitySummary(activity: activity, price: split ? activity.userPrice(uid) : activity.price, showBooking: showBooking),
                Container(height: 10)
              ],
              Padding(
                padding: const EdgeInsets.only(right: 30.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 150,
                    child: Text("${split ? "Your total" : "Total"}\n\$${(split ? trip.userTotalPrice(uid) : trip.totalPrice).toStringAsFixed(2)}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.right,)
                  )
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SummaryHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  const SummaryHeader(this.title, {this.icon,super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: GoogleFonts.kadwa(textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
        if(icon != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(icon, size: 30),
          ),
      ]
    );
  }
}