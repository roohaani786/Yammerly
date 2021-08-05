import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techstagram/services/database.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen(
      {Key key, this.chatRoomID, this.displayName, this.enduser})
      : super(key: key);

  final String chatRoomID;
  final String displayName;
  final String enduser;

  @override
  _ConversationScreenState createState() =>
      _ConversationScreenState(displayName, enduser);
}

class _ConversationScreenState extends State<ConversationScreen>
    with WidgetsBindingObserver {
  _ConversationScreenState(this.displayName, this.enduser);

  Stream chatMessageStream;
  DatabaseService databaseService = new DatabaseService();
  Timer debounce;
  int debounceTime = 500;
  final displayName;
  final enduser;
  bool isTyping = false;
  TextEditingController messageController = new TextEditingController();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) setTyping('false');
  }

  @override
  void initState() {
    DatabaseService().getConversationMessages(widget.chatRoomID).then((value) {
      WidgetsBinding.instance.addObserver(this);
      setState(() {
        chatMessageStream = value;
      });
    });
    messageController.addListener(onSearchChanged);
    setTyping('false');
    isTyping = false;
    super.initState();
  }

  Widget ChatMessageList() {
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
          switch (snap.data.data()["$enduser typing"].toString()) {
            case 'true':
              return AppbarText(text: 'typing..');
            case 'paused':
              return AppbarText(text: 'stopped typing..');
            default:
              return Container();
          }
        });
  }

  onSearchChanged() {
    if (debounce?.isActive ?? false) debounce.cancel();
    debounce = Timer(Duration(milliseconds: debounceTime), () {
      if (messageController.text != '') setTyping('paused');
    });
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
  Widget build(BuildContext context) {
    final height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return SafeArea(
      child: Scaffold(
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
              //padding: EdgeInsets.symmetric(vertical: 16),
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
      ),
    );
  }
}

class AppbarText extends StatelessWidget {
  const AppbarText({Key key, this.text}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  MessageTile(this.message, this.isSendByMe);

  final bool isSendByMe;
  final String message;

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
