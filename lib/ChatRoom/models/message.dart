// import 'package:cloud_firestore/cloud_firestore.dart';

// class MessageChat {
//   final String content;
//   final String idFrom;
//   final String sender;
//   final String timestamp;

//   MessageChat({
//     required this.content,
//     required this.idFrom,
//     required this.sender,
//     required this.timestamp,
//   });

//   factory MessageChat.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return MessageChat(
//       content: data['content'],
//       idFrom: data['idFrom'],
//       sender: data['sender'],
//       timestamp: data['timestamp'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'content': content,
//       'idFrom': idFrom,
//       'sender': sender,
//       'timestamp': timestamp,
//     };
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';

class MessageChat {
  final String content;
  final String idFrom;
  final String sender;
  final String timestamp;
  final String? fileUrl; // New field for file URL

  MessageChat({
    required this.content,
    required this.idFrom,
    required this.sender,
    required this.timestamp,
    this.fileUrl,
  });

  // ... (other methods)

  factory MessageChat.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MessageChat(
      content: data['content'],
      idFrom: data['idFrom'],
      sender: data['sender'],
      timestamp: data['timestamp'],
      fileUrl: data['fileUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'idFrom': idFrom,
      'sender': sender,
      'timestamp': timestamp,
      'fileUrl': fileUrl,
    };
  }
}

