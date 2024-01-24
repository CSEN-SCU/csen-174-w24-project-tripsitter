import 'package:flutter/material.dart';

class NewTrip extends StatelessWidget {
  const NewTrip({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("New Trip"),
      content: Text("Create a new trip?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          child: Text("Cancel")
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          child: Text("Create")
        )
      ]
    );
  }
}