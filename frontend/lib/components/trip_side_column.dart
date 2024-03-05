import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
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
    if(trip == null || user == null) {
      return Container();
    }
    List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
    return Column(
      children: [
        Text("Members: ${trip!.uids.length}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ...profiles.map((UserProfile profile) => ListTile(
          leading: FutureBuilder(
            future: FirebaseStorage.instance.ref('pictures/${profile.id}').getDownloadURL(),
            builder: 
            (BuildContext context, AsyncSnapshot<String> snapshot) {
              return CircleAvatar(
                backgroundImage:
                    (profile.hasPhoto && snapshot.hasData && snapshot.data != null)
                        ? NetworkImage(snapshot.data!)
                        : null,
                child: !(profile.hasPhoto && snapshot.hasData && snapshot.data != null)
                    ? Icon(Icons.person)
                    : null);
            }
          ),
          title: Text(profile.name),
          subtitle: Text(profile.email),
          trailing: trip!.frozen ? (trip!.usingSplitPayments ? Icon(
            (trip!.paymentsComplete[user.uid] ?? false) ? Icons.credit_card : Icons.credit_card_off
          ) : null) : IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () async {
              await TripsitterApi.removeUser(profile.id, trip!.id);
            },
          )
        )).toList(),
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
          icon: Icon(Icons.add),
          label: Text("Add Member")
        ),
        if(!isMobile)
          ...[
            Container(height: 10),
            CheckboxListTile(
              value: trip!.usingSplitPayments,
              title: Text("Split payments"), 
              onChanged: (bool? value) {
                trip!.toggleSplitPayments();
              },
            ),
            if((trip!.usingSplitPayments ? trip!.paymentsComplete[user.uid] != true : !trip!.isConfirmed))
              ElevatedButton.icon(
                icon: Icon(Icons.credit_card),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage(trip: trip!, profiles: profiles)));
                }, 
                label: Text("Checkout"),
              ),
            if((!trip!.isConfirmed && trip!.usingSplitPayments && trip!.paymentsComplete[user.uid] == true))
               Text("Awaiting payment from all members", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if(trip!.isConfirmed)
              Text("Trip is confirmed", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
          ]
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
