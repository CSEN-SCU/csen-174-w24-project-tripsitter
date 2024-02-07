import "package:flutter/material.dart";

class TripsConsolePopup extends StatelessWidget {
  final String index;

  const TripsConsolePopup(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget selectedWidget;
    switch (index) {
      case 'None':
        selectedWidget = Container(color: Colors.red, height: 100, width: 100);
        break;
      case 'Hotel':
        selectedWidget =
            Container(color: Colors.green, height: 100, width: 100);
        break;
      case 'Rental Car':
        selectedWidget = Container(color: Colors.blue, height: 100, width: 100);
        break;
      case 'Flights':
        selectedWidget =
            Container(color: Colors.yellow, height: 100, width: 100);
        break;
      case 'Activities':
        selectedWidget =
            Container(color: Colors.orange, height: 100, width: 100);
        break;
      case 'Cities':
        selectedWidget =
            Container(color: Colors.purple, height: 100, width: 100);
        break;
      default:
        selectedWidget =
            Container(); // You can return a default widget or throw an error
    }
    return selectedWidget;
  }
}
