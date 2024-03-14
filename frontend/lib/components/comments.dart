import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/helpers/api.dart';

class CommentsSection extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;
  final User user;

  const CommentsSection({required this.trip, required this.profiles, required this.user, super.key});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  TextEditingController commentController = TextEditingController();

  Trip get trip => widget.trip;
  List<UserProfile> get profiles => widget.profiles;
  User get user => widget.user;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Discussion",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ...trip.comments
            .map((TripComment comment) => ListTile(
                  subtitle:
                      Text(DateFormat('yyyy-MM-dd – kk:mm').format(comment.date)),
                  isThreeLine: true,
                  title: Text(
                      "${profiles.firstWhereOrNull((element) => element.id == comment.uid)?.name ?? ""}\n${comment.comment}"),
                  trailing: comment.uid == user.uid
                      ? IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await trip.removeComment(comment);
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
                await trip.addComment(TripComment(
                    comment: value, uid: user.uid, date: DateTime.now()));
                commentController.clear();
                if (!mounted) return;
                setState(() {});
              }),
          trailing: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              await trip.addComment(TripComment(
                  comment: commentController.text,
                  uid: user.uid,
                  date: DateTime.now()));
              commentController.clear();
              if (!mounted) return;
              setState(() {});
            },
          ),
        ),
      ]
    );
  }
}