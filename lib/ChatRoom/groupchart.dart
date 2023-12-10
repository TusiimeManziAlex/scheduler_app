import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scheduler_app/ChatRoom/models/message.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({Key? key}) : super(key: key);

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  String _userName = "";
  String groupId = "your_group_id"; // Replace with your group ID logic
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _controller = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    getData();
    _scrollDown();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _scrollDown() {
    if (_controller.hasClients) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    }
  }

  Future<bool> onBackPress() {
    // Handle any necessary cleanup
    Navigator.pop(context);
    return Future.value(false);
  }

  // get the user data
  void getData() async {
    final user = _auth.currentUser;
    final _uid = user?.uid;

    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("SheduleUsers")
        .doc(_uid)
        .get();

    setState(() {
      _userName = userDoc.get("mame");
    });
  }

  // sendGroupChat({required String message}) async {
  //   MessageChat chat = MessageChat(
  //     content: message,
  //     idFrom: currentUserId,
  //     sender: _userName,
  //     timestamp: Timestamp.now().toString(),
  //   );

  //   await FirebaseFirestore.instance
  //       .collection("group")
  //       .doc(groupId)
  //       .collection("messages")
  //       .add(chat.toJson());

  //   _messageController.text = "";
  //   _scrollDown();
  // }

  Future<void> sendGroupChat({required String message, File? pdfFile}) async {
    String? fileUrl;

    // if (pdfFile != null) {
    //   // Upload PDF file to Firebase Storage
    //   final storageRef = FirebaseStorage.instance
    //       .ref()
    //       .child('group_files')
    //       .child('$groupId/${DateTime.now().millisecondsSinceEpoch}.pdf');

    //   final uploadTask = storageRef.putFile(pdfFile);
    //   await uploadTask.whenComplete(() async {
    //     fileUrl = await storageRef.getDownloadURL();
    //   });
    // } else {
    //   fileUrl = null; // No file, set to null
    // }
    if (pdfFile != null) {
      // Upload PDF file to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('group_files')
          .child('$groupId/${DateTime.now().millisecondsSinceEpoch}.pdf');

      final uploadTask = storageRef.putFile(pdfFile);
      await uploadTask.whenComplete(() async {
        fileUrl = await storageRef.getDownloadURL();
      });
    }

    MessageChat chat = MessageChat(
      content: message,
      idFrom: currentUserId,
      sender: _userName,
      timestamp: Timestamp.now().toString(),
      fileUrl: fileUrl,
    );

    await FirebaseFirestore.instance
        .collection("group")
        .doc(groupId)
        .collection("messages")
        .add(chat.toJson());

    _messageController.text = "";
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Group Chat"),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            height: 60,
            width: MediaQuery.of(context).size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 15),
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Enter message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: IconButton(
                        icon: Icon(Icons.attach_file),
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['pdf']);
                          if (result != null) {
                            File file = File(result.files.single.path!);
                            // Handle the selected file (e.g., send it in your sendGroupChat method)
                            // Note: You might need to update your sendGroupChat method to accept a File parameter.
                            sendGroupChat(
                                message: _messageController.text,
                                pdfFile: file);
                          }
                        },
                      ),
                    ),
                    controller: _messageController,
                  ),
                ),
                // Container(
                //   padding: EdgeInsets.fromLTRB(5, 5, 5, 15),
                //   width: MediaQuery.of(context).size.width / 1.5,
                //   child: TextField(
                //     decoration: InputDecoration(
                //       label: Text("Enter message"),
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(10),
                //       ),
                //     ),
                //     controller: _messageController,
                //   ),
                // ),
                SizedBox(width: 15),
                IconButton(
                  onPressed: () {
                    sendGroupChat(message: _messageController.text);
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  icon: Icon(Icons.send),
                  color: Colors.black54,
                  iconSize: 40,
                ),
              ],
            ),
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("group")
              .doc(groupId)
              .collection("messages")
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.docs.length < 1) {
                return const Center(
                  child: Text("No Messages Available !"),
                );
              }

              return ListView.builder(
                reverse: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  MessageChat chat =
                      MessageChat.fromDocument(snapshot.data!.docs[index]);

                  bool isCurrentUser = chat.idFrom == currentUserId;

                  return Align(
                    alignment: isCurrentUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? Colors.blueAccent
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chat.content,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chat.sender,
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          if (chat.fileUrl != null)
                            ElevatedButton(
                              onPressed: () async {
                                // Check if the chat has a fileUrl
                                if (chat.fileUrl != null &&
                                    chat.fileUrl!.isNotEmpty) {
                                  // Launch the default browser to open the file URL
                                  await launch(chat.fileUrl!);
                                } else {
                                  // Handle case when file URL is not available
                                  print('File URL not available');
                                }
                              },
                              child: const Text('Download PDF'),
                            ),
                        ],
                      ),
                    ),
                  );

                  // return Align(
                  //   alignment: isCurrentUser
                  //       ? Alignment.centerRight
                  //       : Alignment.centerLeft,
                  //   child: Container(
                  //     margin: const EdgeInsets.all(8),
                  //     padding: const EdgeInsets.all(12),
                  //     decoration: BoxDecoration(
                  //       color: isCurrentUser
                  //           ? Colors.blueAccent
                  //           : Colors.grey[300],
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           chat.content,
                  //           style: const TextStyle(
                  //             color: Colors.black,
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //         const SizedBox(height: 4),
                  //         Text(
                  //           chat.sender,
                  //           style: const TextStyle(
                  //             color: Colors.black54,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
