import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class TripSitterNavbar extends StatelessWidget implements PreferredSizeWidget {
  const TripSitterNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'TripSitter',
        style: GoogleFonts.kadwa(
          textStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Image.asset('tripsitter_logo.png'),
      ),
      backgroundColor: HexColor("#C6D6FF"),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0), // Set the height of the border
        child: Container(
          color: const Color.fromARGB(
              255, 128, 128, 128), // Set the color of the border
          height: 1.0, // Set the height of the border
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}