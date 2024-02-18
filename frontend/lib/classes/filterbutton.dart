import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final GlobalKey globalKey;
  final Icon icon; // Add this line

  const FilterButton({
    required this.text,
    required this.onPressed,
    required this.globalKey,
    required this.icon, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: globalKey,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(text),
          icon, // Update this line
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
      ),
    );
  }
}