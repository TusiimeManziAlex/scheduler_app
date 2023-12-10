import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import 'constants/Firebasae_constant.dart';
import 'constants/mediaquery.dart';
import 'models/message_chat.dart';
// import 'resources/encryption.dart';
import 'widgets/chatBubble.dart';

class Chat_Screen extends StatefulWidget {
  final String uid;
  Chat_Screen({Key? key, required this.uid}) : super(key: key);

  @override
  State<Chat_Screen> createState() => _Chat_ScreenState();
}

class _Chat_ScreenState extends State<Chat_Screen> {
  String groupChatId = "";
  String currentUserId = "";
  String peerId = "";

  generateGroupId() {
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    peerId = widget.uid;

    if (currentUserId.compareTo(peerId) > 0) {
      groupChatId = '$currentUserId-$peerId';
    } else {
      groupChatId = '$peerId-$currentUserId';
    }

    updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: peerId},
    );
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  sendChat({required String messaage}) async {
    final String encmess = messaage;
    MessageChat chat = MessageChat(
        content: encmess,
        idFrom: currentUserId,
        idTo: peerId,
        timestamp: Timestamp.now().toString());

    await FirebaseFirestore.instance
        .collection("groupMessages")
        .doc(groupChatId)
        .collection("messages")
        .add(chat.toJson());

    _messageController.text = "";
    //
  }

  @override
  void initState() {
    generateGroupId();
    _scrollDown();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _controller = ScrollController();

  void _scrollDown() {
    if (_controller.hasClients) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    }
  }

  Future<bool> onBackPress() {
    updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: null},
    );
    Navigator.pop(context);

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                onBackPress();
              }),
          title: const Text("Your Chats"),
          centerTitle: true,
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            height: 60,
            width: media(context).width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 15),
                  width: media(context).width / 1.5,
                  child: TextField(
                    decoration: InputDecoration(
                      label: Text("Enter message"),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    controller: _messageController,
                  ),
                ),
                SizedBox(width: 15,),
                IconButton(
                    onPressed: () {
                      sendChat(messaage: _messageController.text);
                      _messageController.text = "";
                      _scrollDown();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    icon: Icon(Icons.send),color: Colors.black54,iconSize: 40,)
              ],
            ),
          ),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("groupMessages")
                .doc(groupChatId)
                .collection("messages")
                .orderBy(FirestoreConstants.timestamp, descending: true)
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
                shrinkWrap: true,
                controller: _controller,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  MessageChat chat =
                      MessageChat.fromDocument(snapshot.data!.docs[index]);
                  return ChatBubble(
                      text: chat.content,
                      isCurrentUser:
                          chat.idFrom == currentUserId ? true : false);
                },
              );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}
