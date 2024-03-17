
// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/comments.dart';
import 'package:tripsitter/components/profile_pic.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/components/checkout/checkout.dart';

class TripSideColumn extends StatefulWidget {
  final Trip? trip;
  const TripSideColumn(this.trip, {super.key});

  @override
  State<TripSideColumn> createState() => _TripSideColumnState();
}

class _TripSideColumnState extends State<TripSideColumn> {
  Trip? get trip => widget.trip;

  @override
  Widget build(BuildContext context) {
    bool isMobile = Provider.of<bool>(context);
    User? user = Provider.of<User?>(context);
    if (trip == null || user == null) {
      return Container();
    }
    List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
    return Column(children: [
      const SizedBox(height: 10.0),
      Text("Members: ${trip!.uids.length}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ...profiles
          .map((UserProfile profile) => ListTile(
              leading: ProfilePicture(profile),
              title: Text(profile.name),
              subtitle: Text(profile.email),
              trailing: trip!.frozen
                  ? ((trip!.usingSplitPayments && !trip!.isConfirmed)
                      ? Icon((trip!.paymentsComplete[profile.id] ?? false)
                          ? Icons.credit_card
                          : Icons.credit_card_off)
                      : null)
                  : IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () async {
                        await TripsitterApi.removeUser(profile.id, trip!.id);
                      },
                    )))
          .toList(),
      if(!trip!.frozen)
        TextButton.icon(
            onPressed: () async {
              String? email = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return const AddMemberDialog();
                  });
              if (email != null) {
                await TripsitterApi.addUser(email, trip!.id);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Member")),
      const SizedBox(height: 20.0),
      if (!isMobile) ...[
        CommentsSection(trip: trip!, profiles: profiles, user: user),
        Container(height: 10),
        if(!trip!.frozen)
          CheckboxListTile(
            value: trip!.usingSplitPayments,
            title: const Text("Split Payments"),
            onChanged: (bool? value) {
              trip!.toggleSplitPayments();
            },
          ),
        if ((trip!.usingSplitPayments
            ? trip!.paymentsComplete[user.uid] != true
            : !trip!.isConfirmed))
          ElevatedButton.icon(
            icon: const Icon(Icons.credit_card),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CheckoutPage(trip: trip!, profiles: profiles)));
            },
            label: const Text("Checkout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 125, 175, 220),
              foregroundColor: Colors.black,
            ),
          ),
        if ((!trip!.isConfirmed &&
            trip!.usingSplitPayments &&
            trip!.paymentsComplete[user.uid] == true))
          const Text("Awaiting payment from all members",
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        if (trip!.isConfirmed)
          const Text("Trip is confirmed",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(context: context, builder: (context) => 
              AlertDialog(
                title: const Text("Delete Trip"),
                content: const Text("Are you sure you want to delete this trip?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    }, 
                    child: const Text("Cancel")
                  ),
                  TextButton(
                    onPressed: () async {
                      await trip?.delete();
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/");
                    }, 
                    child: const Text("Delete")
                  )
                ]
            ));
          }, 
          icon: const Icon(Icons.delete), 
          label: const Text("Delete Trip")
        )
      ],
      
    ]);
  }
}

class AddMemberDialog extends StatefulWidget {
  const AddMemberDialog({super.key});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Member"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: "Email"),
        ),
        const SizedBox(height: 10.0),
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context, _emailController.text);
            },
            child: const Text("Add")),
        const SizedBox(height: 10.0),
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"))
      ]),
    );
  }
}
