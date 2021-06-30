import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techstagram/services/database.dart';
import 'conversation.dart';

class SearchtoMessage extends StatefulWidget {
  DatabaseService databaseService = new DatabaseService();
  final String displayNamecurrentUser;
  final String uidX;

  SearchtoMessage({this.displayNamecurrentUser, this.uidX});

  @override
  _searchtomessageState createState() => _searchtomessageState(
      displayNamecurrentUser: displayNamecurrentUser, uidX: uidX);
}

class _searchtomessageState extends State<SearchtoMessage> {
  String fname = "";
  String lname = "";
  String searchKey;
  Stream streamQuery;
  final displayNamecurrentUser;
  final uidX;

  _searchtomessageState({this.displayNamecurrentUser, this.uidX});

  String uidf = SearchtoMessage().uidX;

  createChatRoombySearch(String searchKey) {
    String chatRoomID = getChatRoomId(searchKey, displayNamecurrentUser);

    List<String> users = [searchKey, displayNamecurrentUser];
    Map<String, dynamic> chatRoomMap = {
      "users": users,
      "chatRoomID": chatRoomID
    };
    DatabaseService().createChatRoom(chatRoomID, chatRoomMap);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ConversationScreen(
                chatRoomID: chatRoomID,
                displayName: displayNamecurrentUser,
                enduser: searchKey)));
  }

  Stream ChatRoomStream;

  Widget chatRoomList() {
    return StreamBuilder(
        stream: ChatRoomStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    print(snapshot.data.documents[index]);
                    print("isme kya hai");
                    return ChatRoomsTile(
                        snapshot.data.documents[index]
                            .data()["chatroomID"]
                            .toString()
                            .replaceAll("_", "")
                            .replaceAll(displayNamecurrentUser, ""),
                        snapshot.data.documents[index].data()["chatroomID"]);
                  })
              : Container();
        });
  }

  @override
  void initState() {
    DatabaseService().getChatRooms(displayNamecurrentUser).then((value) {
      setState(() {
        ChatRoomStream = value;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("cv");
    print(uidX);
    print("434");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          color: Colors.white,
          child: TextField(
            decoration: InputDecoration(
//                prefixIcon: Icon(Icons.search,color: Colors.white,),
                hintText: ' Search...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.black,
                )),
            onChanged: (val) {
              setState(() {
//                fname = val;
                searchKey = val;
                streamQuery = FirebaseFirestore.instance
                    .collection('users')
                    .where('displayName', isGreaterThanOrEqualTo: searchKey)
                    .where('displayName', isLessThan: searchKey + 'z')
                    .snapshots();
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (searchKey != "" && searchKey != null)
            ? streamQuery
            :
//        FirebaseFirestore.instance.collection("users").snapshots(),
//        (fname != "" && fname != null)
            FirebaseFirestore.instance
                .collection('users')
                .where("searchKeywords", arrayContains: fname)
                .snapshots(),
//            : FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(
                  child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/profileedit.png'),
                          fit: BoxFit.cover,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator()))
              : ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
//              DocumentSnapshot sd = snapshot.data.docs[index];
                    searchKey = snapshot.data.docs[index]["displayName"];
                    String photoUrl = snapshot.data.docs[index]["photoURL"];
                    String uid = snapshot.data.docs[index]["uid"];
                    String displayName =
                        snapshot.data.docs[index]["displayName"];
                    print(displayName);
                    return (searchKey != null)
                        ? Card(
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 25,
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    print("user pe click kiya");
                                    createChatRoombySearch(searchKey);
                                    // print(searchKey);
                                  },
                                  child: Row(
                                    children: [
                                      (photoUrl != null)
                                          ? CircleAvatar(
                                              radius: 20,
                                              backgroundImage:
                                                  NetworkImage(photoUrl),
                                              backgroundColor:
                                                  Colors.transparent,
                                            )
                                          : CircleAvatar(
                                              radius: 20,
                                              child: IconButton(
                                                  icon: Icon(
                                                    FontAwesomeIcons.userCircle,
                                                    color: Colors.deepPurple,
                                                  ),
                                                  onPressed: null),
                                              backgroundColor:
                                                  Colors.transparent,
                                            ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20.0),
                                        child: Text(
                                          searchKey,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container();
                  },
                );
        },
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  print(a);
  print(b);
  print("get chat");
  print(a.substring(0, 1).codeUnitAt(0));
  print(b.substring(0, 1).codeUnitAt(0));
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    print(a);
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomID;

  ChatRoomsTile(this.userName, this.chatRoomID);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("chatscreen");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConversationScreen(
                      chatRoomID: chatRoomID,
                    )));
      },
      child: Container(
          color: Colors.black26,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(40)),
                  child: Text("${userName.substring(0).toUpperCase()}")),
              SizedBox(width: 8),
              Text(
                userName,
                style: TextStyle(color: Colors.white),
              )
            ],
          )),
    );
  }
}
