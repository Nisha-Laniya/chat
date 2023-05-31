import 'package:auth/helper/constants.dart';
import 'package:auth/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'conversation_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();

  QuerySnapshot? searchSnapshot;

  initiateSearch() {
    FirebaseServices().getUserByUsername(searchController.text).then((val) {
      setState(() {
        searchSnapshot = val;
      });
    });
  }

  getChatRoomId(String a, String b) {
    if(a.substring(0,1).codeUnitAt(0) > b.substring(0,1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  //create chatroom,send user to conversation screen
  createChatRoomAndStartConversation({required String username}) {
    if(username != Constants.myName) {
      String chatRoomId = getChatRoomId(username, Constants.myName);
      List<String> users = [username,Constants.myName];
      Map<String,dynamic> chatRoomMap = {
        "users": users,
        "chatroomId" : chatRoomId,
      };
      FirebaseServices().createChatRoom(chatRoomId, chatRoomMap);
      Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationScreen(chatRoomId: chatRoomId,)));
    } else {
      print('You can not send message to yourself');
    }
  }

  Widget searchList() {
    return searchSnapshot != null ? ListView.builder(
        itemCount: searchSnapshot?.docs.length,
        shrinkWrap: true ,
        itemBuilder: (context,index) {
          return SearchTile(username: searchSnapshot?.docs[index]["Name"], email: searchSnapshot?.docs[index]["Email"]);
    }) : Container();
  }

  Widget SearchTile({required String username, required String email}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username),
              Text(email),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap:() {
              createChatRoomAndStartConversation(username: username);
            },
            child: Container(
              decoration: BoxDecoration(color: Colors.blue,borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 16),
              child: const Text(
                  'Message'
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initiateSearch();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration:
                        const InputDecoration(hintText: 'Search Username...'),
                    controller: searchController,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                   initiateSearch();
                  },
                  child: Container(
                    height: 50,
                    width: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0x36FFFFFF),
                          Color(0x0FFFFFFF),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.search,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          searchList(),
        ],
      ),
    );
  }
}