import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/pages/checkout.dart';

class TripSideColumn extends StatefulWidget {
  final Trip? trip;
  const TripSideColumn(this.trip, {super.key});

  @override
  State<TripSideColumn> createState() => _TripSideColumnState();
}

class _TripSideColumnState extends State<TripSideColumn> {
  String? image = null;
  @override
  Widget build(BuildContext context) {
    if (widget.trip == null) {
      return Container();
    }
    List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
    UserProfile? profile = Provider.of<UserProfile?>(context);
    if (image == null && (profile?.hasPhoto ?? false)) {
      FirebaseStorage.instance
          .ref('pictures/${profile!.id}')
          .getDownloadURL()
          .then((a) {
        if (mounted) setState(() => image = a);
      });
    }
    return Column(children: [
      Text("Members: ${widget.trip!.uids.length}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ...profiles
          .map((UserProfile profile) => ListTile(
              leading: CircleAvatar(
                backgroundImage: (profile.hasPhoto && image != null)
                    ? NetworkImage(image!)
                    : null,
                child: !profile.hasPhoto ? const Icon(Icons.person) : null,
              ),
              title: Text(profile.name),
              subtitle: Text(profile.email),
              trailing: IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () async {
                  await TripsitterApi.removeUser(profile.id, widget.trip!.id);
                },
              )))
          .toList(),
      TextButton.icon(
          onPressed: () async {
            String? email = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return const AddMemberDialog();
                });
            if (email != null) {
              await TripsitterApi.addUser(email, widget.trip!.id);
            }
          },
          icon: Icon(Icons.add),
          label: Text("Add Member")
        ),
        Container(height: 10),
        ElevatedButton.icon(
          icon: Icon(Icons.credit_card),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage(trip: widget.trip!, profiles: profiles)));
          }, 
          label: Text("Checkout"),
        )
      ]
    );
  }
}

class AddMemberDialog extends StatefulWidget {
  const AddMemberDialog({super.key});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Member"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: "Email"),
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context, _emailController.text);
            },
            child: Text("Add")),
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"))
      ]),
    );
  }
}
