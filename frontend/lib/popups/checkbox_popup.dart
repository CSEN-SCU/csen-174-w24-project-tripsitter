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
        button.localToGlobal(Offset.zero) + Offset(0, button.size.height),
      ),
      Offset.zero & overlay.size,
    );

    List<String> tempSelected = List.from(selected);
    bool isAllSelected = tempSelected.length == options.length;
    String selectAllLabel = isAllSelected ? 'Deselect All' : 'Select All';

    await showMenu<void>(
      context: context,
      position: position,
      items: [
        PopupMenuItem<void>(
          child: ListTile(
            leading: isAllSelected ? Icon(Icons.clear) : Icon(Icons.select_all),
            title: Text(selectAllLabel),
            onTap: () {
              if (isAllSelected) {
                tempSelected.clear();
              } else {
                tempSelected = List.from(options);
              }
              onSelected(List.from(tempSelected));
              Navigator.pop(context);
            },
          ),
        ),
        ...options.map((String option) {
          return PopupMenuItem<void>(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                final bool isChecked = tempSelected.contains(option);
                return CheckboxListTile(
                  title: Text(option),
                  value: isChecked,
                  onChanged: (bool? value) {
                    if (value == true) {
                      tempSelected.add(option);
                    } else {
                      tempSelected.remove(option);
                    }
                    isAllSelected = tempSelected.length == options.length;
                    setState(() {});
                    onSelected(List.from(tempSelected));
                  },
                );
              },
            ),
          );
        }).toList(),
      ],
      elevation: 8.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
