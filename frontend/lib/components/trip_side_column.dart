
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
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
  TextEditingController commentController = TextEditingController();

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
                  ? (trip!.usingSplitPayments
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
      const Text("Discussion",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ...trip!.comments
          .map((TripComment comment) => ListTile(
                subtitle:
                    Text(DateFormat('yyyy-MM-dd – kk:mm').format(comment.date)),
                isThreeLine: true,
                title: Text(
                    "${profiles.firstWhere((element) => element.id == comment.uid).name}\n${comment.comment}"),
                // leading: ProfilePicture(profiles.firstWhere((element) => element.id == comment.uid)),
                trailing: comment.uid == user.uid
                    ? IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await trip!.removeComment(comment);
                          if (!mounted) return;
                          setState(() {});
                        },
                      )
                    : null,
              ))
          .toList(),
      ListTile(
        title: TextField(
            controller: commentController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Add Comment',
            ),
            onSubmitted: (String value) async {
              await trip!.addComment(TripComment(
                  comment: value, uid: user.uid, date: DateTime.now()));
              commentController.clear();
              if (!mounted) return;
              setState(() {});
            }),
        trailing: IconButton(
          icon: const Icon(Icons.send),
          onPressed: () async {
            await trip!.addComment(TripComment(
                comment: commentController.text,
                uid: user.uid,
                date: DateTime.now()));
            commentController.clear();
            if (!mounted) return;
            setState(() {});
          },
        ),
      ),
      if (!isMobile) ...[
        Container(height: 10),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
      ]
    ]);
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
