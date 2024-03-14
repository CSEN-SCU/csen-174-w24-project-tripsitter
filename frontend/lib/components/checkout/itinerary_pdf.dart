import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

Future<pw.Document> generateItineraryPDF(
    Trip trip, List<UserProfile> profiles) async {
  final doc = pw.Document(pageMode: PdfPageMode.outlines);

  // Load the font
  final fontData = await rootBundle.load("fonts/Roboto-Black.ttf");
  final ttf = pw.Font.ttf(fontData.buffer.asByteData());

  doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return [
          pw.Header(
              level: 0,
              child: pw.Text(trip.name,
                  style: pw.TextStyle(fontSize: 24, font: ttf))),
          pw.Paragraph(
              text:
                  "Destination: ${trip.destination.name}, ${trip.destination.country}",
              style: pw.TextStyle(font: ttf)),
          pw.Paragraph(
              text:
                  "Dates: ${DateFormat('MMM d, yyyy').format(trip.startDate)} - ${DateFormat('MMM d, yyyy').format(trip.endDate)}",
              style: pw.TextStyle(font: ttf)),
          // Add more sections as needed, using the `ttf` font for text
        ];
      }));

  return doc;
}
