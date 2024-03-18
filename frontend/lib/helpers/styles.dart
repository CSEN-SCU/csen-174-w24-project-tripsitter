import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

TextStyle summaryHeaderStyle = const TextStyle(
    decoration: TextDecoration.underline,
);

TextStyle sectionHeaderStyle = GoogleFonts.kadwa(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
);


ButtonStyle buttonStyle = ElevatedButton.styleFrom(
  backgroundColor: HexColor("#C6D6FF"),
  foregroundColor: Colors.black,
);

ButtonStyle buttonStyle2 = ElevatedButton.styleFrom(
  backgroundColor: HexColor("#DDDDDD"),
  foregroundColor: Colors.black,
);