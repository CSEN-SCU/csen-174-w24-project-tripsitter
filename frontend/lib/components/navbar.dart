import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class TripSitterNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool backButton;
  final bool homeButton;
  const TripSitterNavbar({this.title = "TripSitter", this.backButton = false, this.homeButton = true, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: InkWell(
        onTap: homeButton ? () {
          if(ModalRoute.of(context)?.settings.name != "/") {
            Navigator.pushNamed(context, "/");
          }
        } : null,
        child: Text(
          title,
          style: GoogleFonts.kadwa(
            textStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: title == "TripSitter" ? 36 : 24,
            ),
          ),
        ),
      ),
      leading: backButton ? const BackButton() : InkWell(
        onTap: () {
          if(ModalRoute.of(context)?.settings.name != "/") {
            Navigator.pushNamed(context, "/");
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset('assets/tripsitter_logo.png'),
        ),
      ),
      backgroundColor: HexColor("#C6D6FF"),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0), // Set the height of the border
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
