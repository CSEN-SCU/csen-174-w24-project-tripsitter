import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final GlobalKey globalKey;
  final Widget icon; // Add this line
  final Color color;

  const FilterButton({
    required this.text,
    required this.onPressed,
    required this.globalKey,
    required this.icon, // Add this line
    this.color = const Color.fromRGBO(224, 224, 224, 1),
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
        backgroundColor: color,
        foregroundColor: Colors.black,
      ),
    );
  }
}
