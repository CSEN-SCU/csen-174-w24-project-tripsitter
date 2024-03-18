import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:googleapis/script/v1.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/helpers/formatters.dart';

Future<pw.Document> generateItineraryPDF(
    Trip trip, List<UserProfile> profiles, String uid) async {
  final doc = pw.Document(pageMode: PdfPageMode.outlines);

  // Load the font
  final robotoBlackData = await rootBundle.load("assets/fonts/Roboto-Black.ttf");
  final robotoLightData = await rootBundle.load("assets/fonts/Roboto-Light.ttf");
  final robotoItalicData =
      await rootBundle.load("assets/fonts/Roboto-LightItalic.ttf");
  final blackTtf = pw.Font.ttf(robotoBlackData.buffer.asByteData());
  final lightTtf = pw.Font.ttf(robotoLightData.buffer.asByteData());
  final italicTtf = pw.Font.ttf(robotoItalicData.buffer.asByteData());
  final titleStyle = pw.TextStyle(fontSize: 26, font: blackTtf);
  final sectionTitleStyle = pw.TextStyle(fontSize: 18, font: blackTtf);
  final heavyStyle = pw.TextStyle(fontSize: 11, font: blackTtf);
  final contentStyle = pw.TextStyle(fontSize: 11, font: lightTtf);
  final heavyLinkStyle = pw.TextStyle(
      fontSize: 11,
      font: blackTtf,
      color: PdfColors.blue,
      decoration: pw.TextDecoration.underline);
  final linkStyle = pw.TextStyle(
      fontSize: 11,
      font: lightTtf,
      color: PdfColors.blue,
      decoration: pw.TextDecoration.underline);
  final italicizedContentStyle = pw.TextStyle(fontSize: 11, font: italicTtf);

  // Helper functions to format dates and times for the PDF.
  final dateFormatter = DateFormat('E, MMM d, y');
  final timeFormatter = DateFormat('h:mm a');

  // Load icons
  final tripSitterIconData = await rootBundle.load('assets/tripsitter_logo.png');
  final flightIconData = await rootBundle.load('assets//icons/flight_icon.png');
  final hotelIconData = await rootBundle.load('assets//icons/hotel_icon.png');
  final carIconData = await rootBundle.load('assets//icons/car_icon.png');
  final activityIconData = await rootBundle.load('assets//icons/activity_icon.png');
  final restaurantIconData =
      await rootBundle.load('assets//icons/restaurant_icon.png');
  final tripSitterLogo =
      pw.MemoryImage(tripSitterIconData.buffer.asUint8List());
  final flightIcon = pw.MemoryImage(flightIconData.buffer.asUint8List());
  final hotelIcon = pw.MemoryImage(hotelIconData.buffer.asUint8List());
  final carIcon = pw.MemoryImage(carIconData.buffer.asUint8List());
  final activityIcon = pw.MemoryImage(activityIconData.buffer.asUint8List());
  final restaurantIcon =
      pw.MemoryImage(restaurantIconData.buffer.asUint8List());

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.all(32),
    build: (pw.Context context) {
      return [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(width: 2, color: PdfColors.grey)),
            ),
            padding: pw.EdgeInsets.only(
                bottom: 3), // Space between text and underline
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(trip.name, style: titleStyle),
                  pw.Column(children: [
                    pw.Image(tripSitterLogo, width: 40, height: 40),
                    pw.SizedBox(height: 5),
                  ]),
                ]),
          ),
          pw.SizedBox(height: 10),
          pw.UrlLink(
              destination: 'https://tripsitter-travel.web.app/trip/${trip.id}',
              child: pw.Text("View this trip on TripSitter",
                  style: heavyLinkStyle)),
          pw.Row(children: [
            pw.Text("Destination: ", style: heavyStyle),
            pw.Text("${trip.destination.name}, ${trip.destination.country}",
                style: contentStyle)
          ]),
          pw.Row(children: [
            pw.Text("Dates: ", style: heavyStyle),
            pw.Text(
                "${DateFormat('MMM d, yyyy').format(trip.startDate)} - ${DateFormat('MMM d, yyyy').format(trip.endDate)}",
                style: contentStyle)
          ]),
          pw.Row(children: [
            pw.Text("Members: ", style: heavyStyle),
            pw.Text(
                "${profiles.where((profile) => trip.uids.contains(profile.id)).map((profile) => profile.name).join(', ')}",
                style: contentStyle)
          ]),
        ]),

        // Flights
        if (trip.flights.isNotEmpty) ...[
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(width: 2, color: PdfColors.grey)),
            ),
            padding: pw.EdgeInsets.only(
                bottom: 3), // Space between text and underline
            margin: pw.EdgeInsets.symmetric(vertical: 10),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Flights', style: sectionTitleStyle),
                pw.SizedBox(width: 5),
                pw.Image(flightIcon, width: 24, height: 24),
              ],
            ),
          ),
          ...trip.flights.map((flight) {
            final price = flight
                .price; // Adjust according to how you get the total price for a flight.
            final memberNames = flight.members
                .map((id) =>
                    profiles
                        .firstWhereOrNull((profile) => profile.id == id)
                        ?.name ??
                    'Unknown')
                .join(', ');
            // Use a counter to differentiate between "Departing" and "Returning".
            int itineraryCounter = 0;

            return pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              "${flight.departureAirport} -> ${flight.arrivalAirport}" +
                                  (flight.pnr != null
                                      ? " (Confirmation: ${flight.pnr})"
                                      : ""),
                              style: heavyStyle),
                          pw.Text(memberNames, style: contentStyle),
                          ...flight.selected?.itineraries.map((it) {
                                String flightPhase = itineraryCounter == 0
                                    ? 'Departing:'
                                    : 'Returning:';
                                itineraryCounter++;
                                String planesText =
                                    "Plane${it.segments.length > 1 ? 's' : ''}: ${it.segments.map((e) => "${Airline.fromCode(e.carrierCode)?.name ?? e.carrierCode} ${e.number}").join(", ")}";
                                return pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Row(children: [
                                      pw.Text("$flightPhase ",
                                          style: heavyStyle),
                                      pw.Text(
                                          "${dateFormatter.format(it.segments.first.departure.at)} from ${timeFormatter.format(it.segments.first.departure.at)} - ${timeFormatter.format(it.segments.last.arrival.at)}" +
                                              "${(it.segments.first.departure.at.day != it.segments.last.arrival.at.day || it.segments.first.departure.at.year != it.segments.last.arrival.at.year || it.segments.first.departure.at.month != it.segments.last.arrival.at.month) ? " (+1)" : ""}",
                                          style: contentStyle),
                                    ]),
                                    pw.Text(planesText, style: contentStyle)
                                  ],
                                );
                              }).toList() ??
                              [],
                        ],
                      ),
                    ),
                    pw.Text(
                        price != null
                            ? "\$${price.toStringAsFixed(2)}"
                            : "Unknown price",
                        style: heavyStyle),
                  ],
                ),
                pw.Divider(),
              ],
            );
          }).toList(),
        ],

        // Hotels
        if (trip.hotels.isNotEmpty) ...[
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(width: 2, color: PdfColors.grey)),
            ),
            padding: pw.EdgeInsets.only(
                bottom: 3), // Space between text and underline
            margin: pw.EdgeInsets.symmetric(vertical: 10),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Hotels', style: sectionTitleStyle),
                pw.SizedBox(width: 5),
                pw.Image(hotelIcon, width: 24, height: 24),
              ],
            ),
          ),
          ...trip.hotels.map(
            (hotel) {
              final price = hotel.price;
              final memberNames = hotel.members
                  .map((id) =>
                      profiles
                          .firstWhereOrNull((profile) => profile.id == id)
                          ?.name ??
                      'Unknown')
                  .join(', ');
              return pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                                "${hotel.name}" +
                                    (hotel.pnr != null
                                        ? " (Confirmation: ${hotel.pnr})"
                                        : ""),
                                style: heavyStyle),
                            pw.Text(memberNames, style: contentStyle),
                            pw.Text(
                              "${dateFormatter.format(DateTime.parse(hotel.selectedOffer!.checkInDate))} - " +
                                  "${dateFormatter.format(DateTime.parse(hotel.selectedOffer!.checkOutDate))}",
                              style: contentStyle,
                            ),
                            pw.UrlLink(
                                destination:
                                    "https://www.google.com/maps/search/${hotel.selectedInfo!.latitude.toString()},${hotel.selectedInfo!.longitude.toString()}?hl=en&source=opensearch",
                                child: pw.Text(hotel.selectedInfo!.name,
                                    style: linkStyle)),
                          ],
                        ),
                      ),
                      pw.Text(
                        price != null
                            ? "\$${price.toStringAsFixed(2)}"
                            : "Unknown price",
                        style: heavyStyle,
                      ),
                    ],
                  ),
                  pw.Divider(),
                ],
              );
            },
          ),
        ],

        // Rental Cars
        if (trip.rentalCars.isNotEmpty) ...[
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(width: 2, color: PdfColors.grey)),
            ),
            padding: pw.EdgeInsets.only(
                bottom: 3), // Space between text and underline
            margin: pw.EdgeInsets.symmetric(vertical: 10),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Rental Cars', style: sectionTitleStyle),
                pw.SizedBox(width: 5),
                pw.Image(carIcon, width: 24, height: 24),
              ],
            ),
          ),
          ...trip.rentalCars.map(
            (rentalCar) {
              final price = rentalCar.price;
              final memberNames = rentalCar.members
                  .map((id) =>
                      profiles
                          .firstWhereOrNull((profile) => profile.id == id)
                          ?.name ??
                      'Unknown')
                  .join(', ');
              return pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              rentalCar.name,
                              style: heavyStyle,
                            ),
                            if (rentalCar.selected?.dplnk != null)
                              pw.UrlLink(
                                  destination:
                                      "https://skyscanner.com${rentalCar.selected!.dplnk}",
                                  child: pw.Text(
                                      "View/Purchase on ${rentalCar.selected?.provider.providerName}",
                                      style: heavyLinkStyle)),
                            pw.Text(memberNames, style: contentStyle),
                            pw.Text(
                                "${rentalCar.selected!.sipp.fromSipp()} ${rentalCar.selected?.carName} or similar",
                                style: contentStyle),
                            pw.Text(
                                "Pickup at ${rentalCar.selected!.provider.providerName} @ ${rentalCar.selected?.pu}, Dropoff at ${rentalCar.selected?.doo}",
                                style: contentStyle),
                          ],
                        ),
                      ),
                      pw.Text(
                          price != null
                              ? "\$${price.toStringAsFixed(2)}"
                              : "Unknown price",
                          style: heavyStyle),
                    ],
                  ),
                  pw.Divider(),
                ],
              );
            },
          ),
        ],

        // Activities
        if (trip.activities.isNotEmpty) ...[
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(width: 2, color: PdfColors.grey)),
            ),
            padding: pw.EdgeInsets.only(
                bottom: 3), // Space between text and underline
            margin: pw.EdgeInsets.symmetric(vertical: 10),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Activities', style: sectionTitleStyle),
                pw.SizedBox(width: 5),
                pw.Column(
                  children: [
                    pw.Image(activityIcon, width: 20, height: 20),
                    pw.SizedBox(height: 2)
                  ],
                )
              ],
            ),
          ),
          ...trip.activities.map(
            (activity) {
              final price = activity.price;
              final memberNames = activity.participants
                  .map((id) =>
                      profiles
                          .firstWhereOrNull((profile) => profile.id == id)
                          ?.name ??
                      'Unknown')
                  .join(', ');
              return pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              activity.event.name,
                              style: heavyStyle,
                            ),
                            if (activity.event.url != null)
                              pw.UrlLink(
                                  destination: activity.event.url!,
                                  child: pw.Text(
                                      "View/Purchase on Ticketmaster",
                                      style: heavyLinkStyle)),
                            pw.Text(memberNames, style: contentStyle),
                            pw.Text(
                                "${activity.event.startTime.getFormattedDate()} at ${activity.event.startTime.getFormattedTime()}",
                                style: contentStyle),
                            pw.UrlLink(
                                destination:
                                    "https://www.google.com/maps/search/${activity.event.venues.first.latitude.toString()},${activity.event.venues.first.longitude.toString()}?hl=en&source=opensearch",
                                child: pw.Text(activity.event.venues.first.name,
                                    style: linkStyle)),
                          ],
                        ),
                      ),
                      pw.Text(
                          price != null
                              ? "\$${price.toStringAsFixed(2)}"
                              : "Unknown price",
                          style: heavyStyle),
                    ],
                  ),
                  pw.Divider(),
                ],
              );
            },
          ),
        ],

        // Restaurants
        if (trip.meals.isNotEmpty) ...[
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(width: 2, color: PdfColors.grey)),
            ),
            padding: pw.EdgeInsets.only(
                bottom: 3), // Space between text and underline
            margin: pw.EdgeInsets.symmetric(vertical: 10),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Restaurants', style: sectionTitleStyle),
                pw.SizedBox(width: 5),
                pw.Column(
                  children: [
                    pw.Image(restaurantIcon, width: 20, height: 20),
                    pw.SizedBox(height: 2)
                  ],
                )
              ],
            ),
          ),
          ...trip.meals.map(
            (meal) {
              final price = meal.price;
              final memberNames = meal.participants
                  .map((id) =>
                      profiles
                          .firstWhereOrNull((profile) => profile.id == id)
                          ?.name ??
                      'Unknown')
                  .join(', ');
              return pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              meal.restaurant.name,
                              style: heavyStyle,
                            ),
                            pw.UrlLink(
                                destination: meal.restaurant.url!,
                                child: pw.Text("View/Reserve on Yelp",
                                    style: heavyLinkStyle)),
                            pw.Text(memberNames, style: contentStyle),
                            pw.UrlLink(
                                destination:
                                    "https://www.google.com/maps/search/" +
                                        meal.restaurant.location.displayAddress
                                            .join(", ") +
                                        "?hl=en&source=opensearch",
                                child: pw.Text(
                                    meal.restaurant.location.displayAddress
                                        .join(", "),
                                    style: linkStyle)),
                          ],
                        ),
                      ),
                      pw.Text(
                        meal.restaurant.price != null
                            ? meal.restaurant.price!
                            : " ",
                        style: heavyStyle,
                      ),
                    ],
                  ),
                  pw.Divider(),
                ],
              );
            },
          ),
        ],

        // Summary
        pw.Paragraph(
          text: "Total: \$${trip.totalPrice.toStringAsFixed(2)}",
          style: titleStyle,
        ),

        pw.Paragraph(
          text:
              "Generated by TripSitter on ${dateFormatter.format(DateTime.now())} at ${timeFormatter.format(DateTime.now())}",
          style: heavyStyle,
        )
      ];
    },
  ));

  return doc;
}
