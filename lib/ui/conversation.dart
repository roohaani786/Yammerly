import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techstagram/services/database.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomID;
  final String displayName;
  final String enduser;

  const ConversationScreen(
      {Key key, this.chatRoomID, this.displayName, this.enduser})
      : super(key: key);

  @override
  _ConversationScreenState createState() =>
      _ConversationScreenState(displayName, enduser);
}

class _ConversationScreenState extends State<ConversationScreen>
    with WidgetsBindingObserver {
  DatabaseService databaseService = new DatabaseService();
  TextEditingController messageController = new TextEditingController();
  final displayName;
  final enduser;

  _ConversationScreenState(this.displayName, this.enduser);

  Widget ChatMessageList() {
    print('display name ' + displayName);
    print('enduser ' + enduser);
    return StreamBuilder(
        stream: chatMessageStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //   onlineCheck();
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      snapshot.data.docs[index].data()["message"],
                      snapshot.data.docs[index].data()["sendBy"] ==
                          displayName);
                });
          } else {
            return Container();
          }
        });
  }

  Stream chatMessageStream;

  SendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
        "sendBy": displayName,
        "time": DateTime.now().microsecondsSinceEpoch
      };
      DatabaseService().addConversationMessages(widget.chatRoomID, messageMap);
    }
    messageController.text = '';
  }

  // Future<dynamic> getUserInfo() async {
  //   String id = '';
  //   print('userName fetched ' + widget.enduser);
  //   await FirebaseFirestore.instance
  //       .collection("users")
  //       .where("displayName", isEqualTo: widget.enduser)
  //       .get()
  //       .then((value) {
  //     value.docs.forEach((result) {
  //       id = result.id;
  //     });
  //   });
  //   if (id == '')
  //     return null;
  //   else
  //     return id;
  // }

  bool isTyping = false;
  handleSubmitted(String text) {
    messageController.clear();
    setState(() {
      isTyping = false;
    });
    updateTypingState();
  }

  updateTypingState() {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(widget.chatRoomID)
        .update({"$displayName typing": isTyping});
  }

  Widget typingStatus() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("ChatRoom")
            .doc(widget.chatRoomID)
            .snapshots(),
        builder: (context, snap) {
          if (snap.data.data()["$enduser typing"].toString() == 'true')
            return Text(
              'typing ..',
              textAlign: TextAlign.center,
            );
          else
            return Container();
        });
  }

  @override
  void initState() {
    DatabaseService().getConversationMessages(widget.chatRoomID).then((value) {
      WidgetsBinding.instance.addObserver(this);
      setState(() {
        chatMessageStream = value;
      });
    });
    setTyping('false');
    isTyping = false;
    super.initState();
  }

  setTyping(String val) async {
    await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(widget.chatRoomID)
        .update({
      '$displayName typing': val,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) setTyping('false');
  }

  @override
  Widget build(BuildContext context) {
    final height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(enduser),
        actions: [
          Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: typingStatus())
        ],
      ),
      body: Container(
          child: Stack(
        children: [
          Container(height: height * 0.82, child: ChatMessageList()),
          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (String text) {
                        isTyping = text.length > 0;
                        updateTypingState();
                      },
                      onSubmitted: handleSubmitted,
                      controller: messageController,
                      decoration: InputDecoration(
                          hintText: "Enter Message", border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      isTyping = false;
                      updateTypingState();
                      SendMessage();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;

  MessageTile(this.message, this.isSendByMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSendByMe ? Colors.deepPurple : Colors.grey,
          borderRadius: isSendByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20))
              : BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
        ),
        child: Text(
          message,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
