import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techstagram/services/database.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomID;
  final displayName;
  final enduser;

  const ConversationScreen(
      {Key key, this.chatRoomID, this.displayName, this.enduser})
      : super(key: key);

  @override
  _ConversationScreenState createState() =>
      _ConversationScreenState(displayName, enduser);
}

class _ConversationScreenState extends State<ConversationScreen> {
  DatabaseService databaseService = new DatabaseService();
  TextEditingController messageController = new TextEditingController();
  final displayName;
  final enduser;

  _ConversationScreenState(this.displayName, this.enduser);

  Widget ChatMessageList() {
    return StreamBuilder(
        stream: chatMessageStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
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
      messageController.text = "";
    }
  }

  @override
  void initState() {
    DatabaseService().getConversationMessages(widget.chatRoomID).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(enduser),
      ),
      body: Container(
          child: Stack(
        children: [
          ChatMessageList(),
          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                        hintText: "Enter Message", border: InputBorder.none),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    print("message bheja hai");
                    SendMessage();
                  },
                ),
              ],
            ),
          )
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
