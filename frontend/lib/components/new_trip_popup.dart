import 'package:flutter/material.dart';

class NewTrip extends StatelessWidget {
  const NewTrip({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Trip"),
      content: const Text("Create a new trip?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          child: const Text("Cancel")
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          child: const Text("Create")
        )
      ]
    );
  }
}