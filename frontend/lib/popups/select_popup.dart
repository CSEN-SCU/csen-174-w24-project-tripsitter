import 'package:flutter/material.dart';

class SelectOnePopup extends StatelessWidget {
  final List<String> options;
  final String selected;
  final Function(String) onSelected;

  const SelectOnePopup({
    Key? key,
    required this.options,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  Future<void> showPopup(BuildContext context, GlobalKey key) async {
    final RenderBox button =
        key.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(key.currentContext!)!
        .context
        .findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero + Offset(0, button.size.height)),
        button.localToGlobal(Offset.zero) +
            Offset(button.size.width, button.size.height),
      ),
      Offset.zero & overlay.size,
    );

    final String? selectedValue = await showMenu<String>(
      context: context,
      position: position,
      items: options.map((String value) {
        return PopupMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );

    if (selectedValue != null) {
      onSelected(selectedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
