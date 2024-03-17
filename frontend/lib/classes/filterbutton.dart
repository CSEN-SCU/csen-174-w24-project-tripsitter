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
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:8.0),
      child: ElevatedButton(
        key: globalKey,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(text),
            icon, // Update this line
          ],
        ),
      ),
    );
  }
}
