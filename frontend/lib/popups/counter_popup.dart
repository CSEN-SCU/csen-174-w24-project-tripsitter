import 'package:flutter/material.dart';

Future<void> showCounterPopup({
  required BuildContext context,
  required GlobalKey key,
  required int initialCarryOnCount,
  required int initialCheckedCount,
  required Function(int, int) onCountsChanged,
}) async {
  int newCarryOnCount = initialCarryOnCount;
  int newCheckedCount = initialCheckedCount;

  final RenderBox button = key.currentContext!.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Overlay.of(key.currentContext!)!.context.findRenderObject() as RenderBox;
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(Offset.zero + Offset(0, button.size.height)),
      button.localToGlobal(Offset.zero) +
          Offset(button.size.width, button.size.height),
    ),
    Offset.zero & overlay.size,
  );

  await showMenu<void>(
    context: context,
    position: position,
    items: [
      PopupMenuItem<void>(
        enabled: false, // This item is not selectable
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('# Carry On Bags'),
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        if (newCarryOnCount > 0) {
                          setState(() => newCarryOnCount--);
                        }
                      },
                    ),
                    Text('$newCarryOnCount'),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => setState(() => newCarryOnCount++),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('# Checked Bags'),
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        if (newCheckedCount > 0) {
                          setState(() => newCheckedCount--);
                        }
                      },
                    ),
                    Text('$newCheckedCount'),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => setState(() => newCheckedCount++),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ],
    elevation: 8.0,
  ).then((_) => onCountsChanged(newCarryOnCount, newCheckedCount));
}
