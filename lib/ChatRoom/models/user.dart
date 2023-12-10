// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserModel {
//   final String name;
//   final String role;
//   final String uid;

//   UserModel(
//       {required this.name, required this.role, required this.uid});

//   Map<String, dynamic> toJson() {
//     return {"name": name, "role": role, "uid": uid};
//   }

//   factory UserModel.fromJson(QueryDocumentSnapshot<Map<String, dynamic>> map) {
//     return UserModel(
//         name: map["name"],
//         role: map["role"],
//         uid: map['uid']);
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String name;
  final String role;
  final String uid;

  UserModel({
    required this.name,
    required this.role,
    required this.uid,
  });

  Map<String, dynamic> toJson() {
    return {"name": name, "role": role, "uid": uid};
  }

  factory UserModel.fromJson(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();

    return UserModel(
      name: data["mame"] ?? "", // Use the null-aware operator to handle missing fields
      role: data["role"] ?? "",
      uid: data['uid'] ?? "",
    );
  }
}
