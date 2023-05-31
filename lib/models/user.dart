import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String name;
  final String email;
  final String dob;
  final String gender;
  final String phoneNo;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.dob,
    required this.gender,
    required this.phoneNo,
  });

  toJson() {
    return {
      "Name": name,
      "Email": email,
      "Dob": dob,
      "Gender": gender,
      "Phone no": phoneNo
    };
  }

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return UserModel(
      id: document.id,
      name: data["Name"],
      email: data["Email"],
      dob: data["Dob"],
      gender: data["Gender"],
      phoneNo: data['Phone no'],
    );
  }
}
