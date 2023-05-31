import 'package:auth/services/auth.dart';
import 'package:flutter/material.dart';

import 'helper/constants.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;

  ConversationScreen({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {

  TextEditingController messageController = TextEditingController();
  Stream? chatMessageStream;

  Widget chatMessageList() {
    return StreamBuilder(
        stream: chatMessageStream,
        builder: ((context, snapshot) {
          return snapshot.hasData ? ListView.builder(
            itemCount: snapshot.data!.docs.length,
              itemBuilder: (context,index) {
                return MessageTile(message: snapshot.data!.docs[index]['message'], isSendByMe: snapshot.data!.docs[index]["sendBy"] == Constants.myName,);
              }): Container();
    }));
  }

  sendMessage() {
    if(messageController.text.isNotEmpty) {
      Map<String,dynamic> messageMap ={
        "message": messageController.text,
        "sendBy": Constants.myName,
        "time" : DateTime.now().millisecondsSinceEpoch
      };
      FirebaseServices().addConversationMessages(widget.chatRoomId, messageMap);
      messageController.text = '';
    }
  }

  @override
  void initState() {
    FirebaseServices().getConversationMessages(widget.chatRoomId).then((value){
      setState(() {
        chatMessageStream = value;
      });
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Conversation'),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessageList(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                     Expanded(
                      child: TextField(
                        decoration:
                        InputDecoration(hintText: 'Search Username...',border: InputBorder.none),
                        controller: messageController,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        sendMessage();
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
                          Icons.send,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  const MessageTile({Key? key, required this.message, required this.isSendByMe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
       width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSendByMe? [
               Color(0xFF007EF4),
              Color(0xFF2A75BC)
            ] : [
              Colors.blueGrey,
              Colors.blueGrey,
            ]
          )
        ),
          child: Text(message,style: TextStyle(fontSize: 15),),
      ),
    );
  }
}

