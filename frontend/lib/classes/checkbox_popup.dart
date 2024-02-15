import 'package:flutter/material.dart';

class CheckboxPopup extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final Function(List<String>) onSelected;

  const CheckboxPopup({
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
          button.localToGlobal(Offset(0, button.size.height))),
      Offset.zero & overlay.size,
    );

    // Copy of the selected list to modify
    List<String> currentSelected = List.from(selected);

    final List<String>? newSelected = await showMenu<List<String>>(
      context: context,
      position: position,
      items: options.map((String option) {
        return PopupMenuItem<List<String>>(
          value: currentSelected.contains(option)
              ? currentSelected.where((item) => item != option).toList()
              : [...currentSelected, option],
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return CheckboxListTile(
                title: Text(option),
                value: currentSelected.contains(option),
                onChanged: (bool? value) {
                  if (value == true) {
                    if (!currentSelected.contains(option)) {
                      setState(() {
                        currentSelected.add(option);
                      });
                    }
                  } else {
                    setState(() {
                      currentSelected.remove(option);
                    });
                  }
                },
              );
            },
          ),
        );
      }).toList(),
      elevation: 8.0,
    );

    if (newSelected != null && newSelected != selected) {
      onSelected(newSelected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // This widget is not intended for direct inclusion in the widget tree.
  }
}
