import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class FirebaseServices {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _db = FirebaseFirestore.instance;

  signInWithGoogle() async {
    print("enter");
    try {
      print("google inside");
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      print("inside");
      if(googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);
        await _auth.signInWithCredential(authCredential);
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      print("not respomd");
    }
  }

  signout() {
    _auth.signOut();
    _googleSignIn.signOut();
  }

  Future<UserModel> getUserDetails(String id) async {
    final snapshot = await _db.collection("Users").where("UserId",isEqualTo: id).get();
    final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).single;
    return userData;
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _db.collection("Users").get();
    final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
    return userData;
  }

  getUserByUsername(String username) async {
    return await FirebaseFirestore.instance.collection('Users').where('Name',isEqualTo: username).get();
  }

  createChatRoom(String charRoomId, chatRoomMap) async {
    await FirebaseFirestore.instance.collection('ChatRoom').doc(charRoomId).set(chatRoomMap).catchError((e) => print(e.toString()));
  }

  getUserByUserEmail(String userEmail) async {
    return await FirebaseFirestore.instance.collection('Users').where('Email',isEqualTo: userEmail).get();
  }

  addConversationMessages(String chatRoomId,messageMap) async {
    return await FirebaseFirestore.instance.collection('ChatRoom').doc(chatRoomId).collection('Chats').add(messageMap).catchError((e) => print(e.toString()));
  }

  getConversationMessages(String chatRoomId) async {
    return await FirebaseFirestore.instance.collection('ChatRoom').doc(chatRoomId).collection('Chats').orderBy("time",descending: false).snapshots();
  }
}