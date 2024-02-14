import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/helpers/api.dart';

class TripSideColumn extends StatelessWidget {
  const TripSideColumn({super.key});

  @override
  Widget build(BuildContext context) {
    Trip? trip = Provider.of<Trip?>(context);
    if(trip == null) {
      return Container();
    }
    return Column(
      children: [
        Text("Members: ${trip.uids.length}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ...trip.uids.map((uid) => 
          FutureBuilder<UserProfile>(
            future: UserProfile.getProfileByUid(uid),
            builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
              if(snapshot.connectionState == ConnectionState.done) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: snapshot.data?.photoUrl != null ? NetworkImage(snapshot.data!.photoUrl!) : null,
                    child: snapshot.data?.photoUrl == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(snapshot.data?.name ?? "Unknown user"),
                  subtitle: Text(snapshot.data?.email ?? ""),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () async {
                      await TripsitterApi.removeUser(snapshot.data!.id, trip.id);
                    },
                  )
                );
              } else {
                return Container();
              }
            },
          )
        ),
        TextButton.icon(
          onPressed: () async {
            String? email = await showDialog<String>(
              context: context, 
              builder: (BuildContext context) {
                return const AddMemberDialog();
              }
            );
            if(email != null) {
              await TripsitterApi.addUser(email, trip.id);
            }
          }, 
          icon: Icon(Icons.add),
          label: Text("Add Member")
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: "Email"
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, _emailController.text);
            }, 
            child: Text("Add")
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            }, 
            child: Text("Cancel")
          )
        ]
      ),
    );
  }
}