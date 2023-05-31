import 'package:auth/all_users.dart';
import 'package:auth/chat_room_screen.dart';
import 'package:auth/helper/helper_function.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home_page.dart';
import '../main.dart';
import '../models/user.dart';
import '../services/auth.dart';

class CommonDrawer extends StatelessWidget {
  CommonDrawer({Key? key}) : super(key: key);

  String? userName;
  String? email;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseServices().getUserDetails(
          FirebaseAuth.instance.currentUser?.uid ?? ''),
      builder: (context,snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            UserModel userModel = snapshot.data as UserModel;
            userName = userModel.name;
            email = userModel.email;
            return Drawer(
              child: ListView(children: [
                DrawerHeader(
                    decoration: BoxDecoration(color: Colors.teal),
                    child: Column(
                      children: [
                        Text(userName!),
                        Text(email!),
                      ],
                    )),
                ListTile(
                  leading: const Icon(Icons.logout_outlined),
                  title: const Text('Log out'),
                  onTap: () {
                    FirebaseServices().signout();
                    HelperFunctions.saveUserLoggedInSharedPreference(false);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => const LoginPage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout_outlined),
                  title: Text('Edit Profile'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => EditProfile()));
                  },
                ),
                ListTile(
                  title: Text('All users'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AllUsers()));
                  },
                ),
                ListTile(
                  title: Text('Chat Room'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoomScreen()));
                  },
                )
              ]),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return Center(
              child: Text('Something went wrong'),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

      },
    );
  }
}
