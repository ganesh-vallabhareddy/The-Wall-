import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wall/components/comment.dart';
import 'package:wall/components/like_button.dart';

import '../helper/helper_methods.dart';
import 'comment_button.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final String time;
  final List<String> likes;
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  int commentCount = 0;
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  bool isLiked = false;

  // comment text controller
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  // add a comment
  void addComment(String commentText) {
    // write the comment to firestore under the comments collection for this user post
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now() // remember to format
    });
  }

  // allow a dialog box for inputting comment
  void showCommentDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Add Comment'),
              content: TextField(
                controller: _commentTextController,
                decoration: InputDecoration(hintText: "Write a comment"),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    _commentTextController.clear();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    addComment(_commentTextController.text);
                    Navigator.pop(context);

                    _commentTextController.clear();
                  },
                  child: Text('Post'),
                ),
              ],
            ));
  }

  // toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    // Access the document in Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection("User Posts").doc(widget.postId);
    if (isLiked) {
      // if the post is liked, then add the user email to the likes field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // if the post is now unliked, then remove the user's email from the likes field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // wall post
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //message
              Text(widget.message),
              // user
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    widget.user,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  Text(
                    " . ",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  Text(
                    widget.time,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),

          // buttons

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Like
              Column(
                children: [
                  Column(
                    children: [
                      LikeButton(
                        isLiked: isLiked,
                        onTap: toggleLike,
                      ),
                      SizedBox(
                        height: 5,
                      ),

                      // like counter
                      Text(
                        widget.likes.length.toString(),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(
                width: 10,
              ),
              // Comment
              Column(
                children: [
                  Column(
                    children: [
                      CommentButton(onTap: showCommentDialog),

                      SizedBox(
                        height: 5,
                      ),

                      // Comment counter
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("User Posts")
                            .doc(widget.postId)
                            .collection("Comments")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            commentCount = snapshot.data!.docs.length;
                          } else {
                            commentCount = 0;
                          }

                          return Text(
                            commentCount.toString(),
                            style: TextStyle(color: Colors.grey),
                          );
                        },
                      ),
                      // Comment counter
                    ],
                  ),
                ],
              ),
            ],
          ),

          SizedBox(
            height: 10,
          ),
          // comments under post
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .orderBy("CommentTime", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // show loading circle if no data
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView(
                  shrinkWrap: true, // for nested list
                  physics: NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc) {
                    // get the comment from the firebase
                    final commentData = doc.data() as Map<String, dynamic>;

                    // return the comment
                    return Comment(
                      text: commentData["CommentText"],
                      user: commentData["CommentedBy"],
                      time: formatDate(commentData["CommentTime"]),
                    );
                  }).toList(),
                );
              })
        ],
      ),
    );
  }
}
