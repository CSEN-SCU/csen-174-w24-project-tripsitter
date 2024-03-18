// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsitter/classes/airport.dart';
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/checkout/activity_summary.dart';
import 'package:tripsitter/components/checkout/car_summary.dart';
import 'package:tripsitter/components/checkout/flight_summary.dart';
import 'package:tripsitter/components/checkout/hotel_summary.dart';
import 'package:tripsitter/components/checkout/itinerary_pdf.dart';
import 'package:tripsitter/components/checkout/restaurant_summary.dart';
import 'package:tripsitter/components/map.dart';
import 'package:tripsitter/components/trip_console_dot.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/helpers/data.dart';
import 'package:tripsitter/helpers/styles.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tripsitter/checkout/itinerary_pdf.dart';

class TripSummary extends StatefulWidget {
  final Trip trip;
  final String uid;
  final List<UserProfile> profiles;
  final bool showSplit;
  final bool showBooking;
  const TripSummary(
      {required this.trip,
      required this.uid,
      required this.profiles,
      this.showSplit = true,
      this.showBooking = false,
      super.key});

  @override
  State<TripSummary> createState() => _TripSummaryState();
}

class _TripSummaryState extends State<TripSummary> {
  bool get split => widget.trip.usingSplitPayments && widget.showSplit;

  String? calendarLoading;

  Future<gcal.EventDateTime> getEventDateTime(
      FlightDepartureArrival flight) async {
    List<Airport> airports = await getAirports(context);
    Airport departureAirport =
        airports.firstWhere((a) => a.iataCode == flight.iataCode);
    String departureTimezone = timezoneMap[flight.iataCode] ??
        await TripsitterApi.getAirportTimezone(departureAirport);
    DateTime dt = flight.at;
    debugPrint("$dt");
    tz.initializeTimeZones();
    final airportTz = tz.getLocation(departureTimezone);

    dt = tz.TZDateTime.from(dt.toUtc(), airportTz);
    dt = dt.subtract(dt.timeZoneOffset - DateTime.now().timeZoneOffset);

    return gcal.EventDateTime(dateTime: dt, timeZone: departureTimezone);
  }

  void createCalendarEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("gcalToken");
      if (token == null) return;
      if (mounted) {
        setState(() {
          calendarLoading = "Adding trip to calendar...";
        });
      }
      gapis.AuthClient client = gapis.authenticatedClient(
          http.Client(),
          gapis.AccessCredentials(
            gapis.AccessToken(
              'Bearer',
              token,
              DateTime.now().toUtc().add(const Duration(days: 365)),
            ),
            null, // We don't have a refreshToken
            [gcal.CalendarApi.calendarEventsScope],
          ));

      gcal.CalendarApi(client).events.insert(
          gcal.Event(
            summary: widget.trip.name,
            start: gcal.EventDateTime(date: widget.trip.startDate.toUtc()),
            end: gcal.EventDateTime(date: widget.trip.endDate.toUtc()),
          ),
          "primary");

      for (FlightGroup group
          in widget.trip.flights.where((f) => f.members.contains(widget.uid))) {
        for (FlightItinerary it in group.selected?.itineraries ?? []) {
          for (FlightSegment seg in it.segments) {
            gcal.EventDateTime start = await getEventDateTime(seg.departure);
            gcal.EventDateTime end = await getEventDateTime(seg.arrival);

            gcal.Event event = gcal.Event(
              summary:
                  "Flight ${seg.carrierCode}${seg.number} ${seg.departure.iataCode} - ${seg.arrival.iataCode}",
              description:
                  "Departure: ${DateFormat("MM/dd/yyyy h:mm a").format(seg.departure.at)} (Local Time) \nArrival: ${DateFormat("MM/dd/yyyy h:mm a").format(seg.arrival.at)} (Local Time)\n${group.pnr != null ? "Booking Confirmation: ${group.pnr}" : ""}",
              start: start,
              end: end,
            );
            gcal.Event created =
                await gcal.CalendarApi(client).events.insert(event, "primary");
            debugPrint("Created event ${created.id}");
          }
        }
      }

      for (Activity a in widget.trip.activities
          .where((a) => a.participants.contains(widget.uid))) {
        TicketmasterEvent e = a.event;
        if (e.startTime.dateTimeUtc == null) continue;
        String summary = e.name;
        String description = "${e.url ?? ""}\n\n${e.info.infoStr ?? ""}";
        String location = e.venues.map((e) => e.name).join(", ");
        DateTime start = e.startTime.dateTimeUtc!;
        DateTime end = start.add(const Duration(hours: 4));

        gcal.Event event = gcal.Event(
          summary: summary,
          description: description,
          location: location,
          start: gcal.EventDateTime(dateTime: start.toUtc()),
          end: gcal.EventDateTime(dateTime: end.toUtc()),
        );
        gcal.Event created =
            await gcal.CalendarApi(client).events.insert(event, "primary");
        debugPrint("Created event ${created.id}");
      }
      debugPrint("Added to calendar");
      if (mounted) {
        setState(() {
          calendarLoading = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Events successfully added to calendar'),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error adding to calendar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Error adding to calendar. Trying signing out and back in and try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Provider.of<bool>(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 650,
      ),
      child: MultiProvider(
        providers: [
          Provider.value(value: widget.profiles),
          Provider.value(value: split),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.trip.name, style: sectionHeaderStyle),
            Text(
                "${DateFormat('MMM d, yyyy').format(widget.trip.startDate)} → ${DateFormat('MMM d, yyyy').format(widget.trip.endDate)}",
                style: sectionHeaderStyle.copyWith(fontSize: 15)),
            Text(
                "${widget.trip.destination.name}, ${widget.trip.destination.country}",
                style: sectionHeaderStyle.copyWith(fontSize: 15)),
            Container(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 10,
              children: [
                if (widget.showBooking)
                  ElevatedButton(
                      onPressed: createCalendarEvents,
                      child: Text(calendarLoading ?? "Add to Calendar")),
                if (widget.showBooking) const SizedBox(width: 20),
                ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.95,
                              height: MediaQuery.of(context).size.height * 0.9,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                                color: Colors.white,
                              ),
                              child: Stack(children: [
                                TripsitterMap<int>(
                                    createWidget: (dynamic h) {
                                      return Container();
                                    },
                                    items: [],
                                    trip: widget.trip,
                                    getLat: (r) => 0.0,
                                    getLon: (r) => 0.0,
                                    isSelected: (r) => false,
                                    extras: const [
                                      MarkerType.activity,
                                      MarkerType.hotel,
                                      MarkerType.restaurant,
                                      MarkerType.airport,
                                    ]),
                                const Positioned(
                                  top: 10.0,
                                  right: 10.0,
                                  child: TsCloseButton(),
                                ),
                              ]),
                            ),
                          );
                        },
                      );
                    },
                    child: const Text("Show Trip Map")),
                const SizedBox(width: 20),
                if (widget.showBooking)
                  ElevatedButton(
                      onPressed: () async {
                        pw.Document pdf = await generateItineraryPDF(
                            widget.trip, widget.profiles, widget.uid);
                        if (kIsWeb) {
                          var savedFile = await pdf.save();
                          List<int> fileInts = List.from(savedFile);
                          html.AnchorElement(
                              href:
                                  "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}")
                            ..setAttribute(
                                "download", "${widget.trip.name}.pdf")
                            ..click();
                        } else {
                          await Printing.sharePdf(
                              bytes: await pdf.save(),
                              filename: "${widget.trip.name}.pdf");
                        }
                      },
                      child: Text("Itinerary to PDF")),
              ],
            ),
            if ((split
                    ? widget.trip.flights
                        .where((f) => f.members.contains(widget.uid))
                    : widget.trip.flights)
                .isNotEmpty) ...[
              SummaryHeader(
                  "Flights: \$${(split ? widget.trip.userFlightsPrice(widget.uid) : widget.trip.flightsPrice).toStringAsFixed(2)}${split ? "" : " total"}",
                  icon: Icons.flight_takeoff_rounded),
              for (var flight in (split
                  ? widget.trip.flights
                      .where((f) => f.members.contains(widget.uid))
                  : widget.trip.flights))
                FlightSummary(
                    flight: flight,
                    price: split ? flight.userPrice(widget.uid) : flight.price),
              Container(height: 10)
            ],
            if ((split
                    ? widget.trip.hotels
                        .where((h) => h.members.contains(widget.uid))
                    : widget.trip.hotels)
                .isNotEmpty) ...[
              SummaryHeader(
                  "Hotels: \$${(split ? widget.trip.userHotelsPrice(widget.uid) : widget.trip.hotelsPrice).toStringAsFixed(2)}${split ? "" : " total"}",
                  icon: Icons.hotel_rounded),
              for (var hotel in (split
                  ? widget.trip.hotels
                      .where((h) => h.members.contains(widget.uid))
                  : widget.trip.hotels))
                HotelSummary(
                    hotel: hotel,
                    price: split ? hotel.userPrice(widget.uid) : hotel.price),
              Container(height: 10)
            ],
            if ((split
                    ? widget.trip.rentalCars
                        .where((r) => r.members.contains(widget.uid))
                    : widget.trip.rentalCars)
                .isNotEmpty) ...[
              SummaryHeader(
                  "Rental Cars: \$${(split ? widget.trip.userRentalCarsPrice(widget.uid) : widget.trip.rentalCarsPrice).toStringAsFixed(2)}${split ? "" : " total"}",
                  icon: Icons.directions_car_rounded),
              for (var rentalCar in (split
                  ? widget.trip.rentalCars
                      .where((r) => r.members.contains(widget.uid))
                  : widget.trip.rentalCars))
                CarSummary(
                    car: rentalCar,
                    price: split
                        ? rentalCar.userPrice(widget.uid)
                        : rentalCar.price,
                    showBooking: widget.showBooking),
              Container(height: 10)
            ],
            if ((split
                    ? widget.trip.activities
                        .where((a) => a.participants.contains(widget.uid))
                    : widget.trip.activities)
                .isNotEmpty) ...[
              SummaryHeader(
                  "Activities: \$${split ? widget.trip.userActivitiesPrice(widget.uid) : widget.trip.activitiesPrice} total",
                  icon: Icons.stadium_rounded),
              for (var activity in (split
                  ? widget.trip.activities
                      .where((a) => a.participants.contains(widget.uid))
                  : widget.trip.activities))
                ActivitySummary(
                    activity: activity,
                    price:
                        split ? activity.userPrice(widget.uid) : activity.price,
                    showBooking: widget.showBooking),
              Container(height: 10)
            ],
            if ((split
                    ? widget.trip.meals
                        .where((r) => r.participants.contains(widget.uid))
                    : widget.trip.meals)
                .isNotEmpty) ...[
              SummaryHeader("Restaurants:", icon: Icons.restaurant_rounded),
              for (var meal in (split
                  ? widget.trip.meals
                      .where((r) => r.participants.contains(widget.uid))
                  : widget.trip.meals))
                RestaurantSummary(
                    meal: meal,
                    price: split ? meal.userPrice(widget.uid) : meal.price,
                    showBooking: widget.showBooking),
              Container(height: 10)
            ],
            Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                      width: 150,
                      child: Text(
                        "${split ? "Your total" : "Total"}\n\$${(split ? widget.trip.userTotalPrice(widget.uid) : widget.trip.totalPrice).toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ))),
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
  const SummaryHeader(this.title, {this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(title,
          style: GoogleFonts.kadwa(
              textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline))),
      if (icon != null)
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(icon, size: 30),
        ),
    ]);
  }
}
