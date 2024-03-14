import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/profile_pic.dart';

class CommentsPopup extends StatefulWidget {
  final List<TripComment> comments;
  final List<UserProfile> profiles;
  final Function(String) addComment;
  final Function(TripComment) removeComment;
  final String myUid;
  const CommentsPopup({
    required this.comments, 
    required this.profiles, 
    required this.addComment,
    required this.myUid,
    required this.removeComment,
    super.key});

  @override
  State<CommentsPopup> createState() => _CommentsPopupState();
}

class _CommentsPopupState extends State<CommentsPopup> {
  TextEditingController commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: widget.comments.isNotEmpty,
      label: Text(widget.comments.length.toString()),
      child: PopupMenuButton(
        child: const Icon(Icons.comment),
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return SizedBox(
                    width: 600,
                    child: Column(
                      children: [
                        ...widget.comments.map((TripComment comment) => ListTile(
                          subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm').format(comment.date)),
                          isThreeLine: true,
                          title: Text("${widget.profiles.firstWhereOrNull((element) => element.id == comment.uid)?.name ?? ""}\n${comment.comment}"),
                          leading: widget.profiles.firstWhereOrNull((element) => element.id == comment.uid) == null ?  ProfilePicture(widget.profiles.firstWhere((element) => element.id == comment.uid)) : null,
                          trailing: comment.uid == widget.myUid ? IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await widget.removeComment(comment);
                              if(!mounted) return;
                              setState(() {
                              });
                            },
                          ) : null,
                        )).toList(),
                        ListTile(
                          title: TextField(
                            controller: commentController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Add Comment',
                            ),
                            onSubmitted: (String value) async {
                              await widget.addComment(value);
                              commentController.clear();
                              if(!mounted) return;
                              setState(() {
                              });
                            }
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () async {
                              await widget.addComment(commentController.text);
                              commentController.clear();
                              if(!mounted) return;
                              setState(() {
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
            )
          ];
        },
      ),
    );
  }
}