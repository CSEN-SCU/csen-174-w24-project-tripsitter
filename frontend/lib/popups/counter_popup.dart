import 'package:flutter/material.dart';
import 'package:tripsitter/classes/counter.dart';

Future<List<CounterVariable>> showCounterPopup({
  required BuildContext context,
  required GlobalKey key,
  required List<CounterVariable> variables,
}) async {
  List<CounterVariable> tempVariables = variables
      .map((variable) =>
          CounterVariable(name: variable.name, value: variable.value))
      .toList();

  final RenderBox button = key.currentContext!.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Overlay.of(key.currentContext!).context.findRenderObject() as RenderBox;
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
            return DefaultTextStyle(
              style: TextStyle(color: Colors.black),
              child: Column(
                children: tempVariables.map((variable) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(variable.name),
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.black),
                        onPressed: () {
                          if (variable.value > 0) {
                            setState(() => variable.value--);
                          }
                        },
                      ),
                      Text('${variable.value}'),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.black),
                        onPressed: () => setState(() => variable.value++),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    ],
    elevation: 8.0,
  );

  return tempVariables; // Return the updated variables
}
