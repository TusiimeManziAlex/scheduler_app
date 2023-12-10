// import 'package:constants/Firebasae_constant.dart';
// import 'package:chat_app/models/user.dart';
// import 'package:chat_app/pages/chat_screen.dart';
// import 'package:chat_app/providers/chatProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:scheduler_app/ChatRoom/groupchart.dart';

import 'chat_screen.dart';
import 'models/user.dart';
import 'providers/chatProvider.dart';
import 'package:badges/badges.dart' as badges;

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ChatProvider chatProvider = ChatProvider();
  @override
  void initState() {
    // chatProvider.registerNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(FirebaseAuth.instance.currentUser!.uid);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Users"),
          actions: [
            PopupMenuButton<String>(
              color: Colors.cyan,
              icon: const Icon(Icons.group_add),
              iconSize: 30,
              onSelected: (value) async {
                if (value == 'group') {
                  // final user = FirebaseAuth.instance.currentUser;
                  // final uid = user?.uid;
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GroupChatScreen(),
                      ));
                } else if (value == 'download') {
                  // await generateAndSavePDF(context, sortedEntries);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'group',
                  child: Text('Group Chart'),
                ),
                // const PopupMenuItem<String>(
                //   value: 'download',
                //   child: Text('Download'),
                // ),
              ],
            ),
          ],
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("SheduleUsers")
                .where('uid',
                    isNotEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.docs.length < 1) {
                  return const Center(
                    child: Text("No Users Available !"),
                  );
                }
                print("body:${snapshot.data.docs}");
                return ListView.separated(
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.black),
                  itemCount: snapshot.data!.docs.length,

                  itemBuilder: (context, index) {
                    UserModel user =
                        UserModel.fromJson(snapshot.data!.docs[index]);

                    return InkWell(
                      autofocus: true,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Chat_Screen(uid: user.uid),
                            ));
                      },
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(user.name),
                            badges.Badge(
                              badgeColor: Colors.blue,
                              badgeContent: const Text(
                                "3",
                                style: TextStyle(color: Colors.white),
                              ),
                              child: const Icon(Icons.message),
                            )
                          ],
                        ),
                        subtitle: Text(user.role),
                      ),
                    );
                  },
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}
