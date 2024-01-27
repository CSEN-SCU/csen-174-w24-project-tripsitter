import 'package:flutter/material.dart';

class TripDashBoard extends StatelessWidget {
  const TripDashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color.fromARGB(255, 233, 233, 233),
        width: 75.0,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Container(
                  color: Colors.red,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight * 0.1,
                  child: Text(
                    "Hello",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        ));
  }
}
