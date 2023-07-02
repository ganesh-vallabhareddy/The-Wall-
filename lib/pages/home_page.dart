import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wall/components/text_field.dart';
import 'package:wall/components/wall_post.dart';
import 'package:wall/pages/profile_page.dart';

import '../components/drawer.dart';
import '../helper/helper_methods.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // text controller
  final textController = TextEditingController();

  // post message
  void postMessage() {
    // only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      //store in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }
    // clear the text field
    setState(() {
      textController.clear();
    });
  }

  // navigate to profile page
  void goToProfilePage() {
    Navigator.pop(context);

    // go to new page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('The Wall'),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        elevation: 0,
        actions: [
          //signout
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: () {
          FirebaseAuth.instance.signOut();
        },
      ),
      body: Center(
        child: Column(
          children: [
            //the wall
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .orderBy(
                        "TimeStamp",
                        descending: false,
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final post = snapshot.data!.docs[index];
                            return WallPost(
                              message: post['Message'],
                              user: post['UserEmail'],
                              likes: List<String>.from(post['Likes'] ?? []),
                              postId: post.id,
                              time: formatDate(post['TimeStamp']),
                            );
                          });
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: + ${snapshot.error}'));
                    }
                    return Center(child: CircularProgressIndicator());
                  }),
            ),

            //post message
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  //text field
                  Expanded(
                    child: MyTextField(
                        controller: textController,
                        hintText: 'Write something on the Wall',
                        obscureText: false),
                  ),
                  // post button
                  IconButton(
                    onPressed: postMessage,
                    icon: Icon(Icons.arrow_circle_up),
                  )
                ],
              ),
            ),

            // logged in as
            Text(
              "Logged in as: " + currentUser.email!,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
