import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techstagram/ui/conversation.dart';
import 'package:techstagram/ui/messagesearchlist.dart';

class ConversationPage extends StatefulWidget {
  final displayName;
  ConversationPage(this.displayName);
  @override
  _ConversationPageState createState() => _ConversationPageState(displayName);
}

class _ConversationPageState extends State<ConversationPage> {
  final displayName;
  _ConversationPageState(this.displayName);
//  void _onHorizontalDrag(DragEndDetails details) {
//    if (details.primaryVelocity == 0)
//      // user have just tapped on screen (no dragging)
//      return;
//
//    if (details.primaryVelocity.compareTo(0) == -1) {
//       dispose();
//      return;
//    }
//    else {
//      Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 4)),
//      );
//    }
//  }

  getUserName(List<dynamic> users) {
    print('tst' + users[0]);
    if (users[0] == displayName)
      return users[1];
    else
      return users[0];
  }

  Future<dynamic> getUserInfo(dynamic doc) async {
    String userName = getUserName(doc['users']);
    String pic = '';
    String id = '';
    print('userName fetched ' + userName);
    print('pre test fetch name ' + userName);
    await FirebaseFirestore.instance
        .collection("users")
        .where("displayName", isEqualTo: userName)
        .get()
        .then((value) {
      value.docs.forEach((result) {
        pic = result.data()['photoURL'];
        id = result.id;
      });
    });
    if (pic == '')
      return null;
    else
      return [pic, id];
  }

  Widget onlineStatus(String id) {
    return StreamBuilder(
      stream:
      FirebaseFirestore.instance.collection("users").doc(id).snapshots(),
      builder: (context, snap) {
        if (snap.data.data()['online'] == 'true')
          return Text('online', style: TextStyle(fontStyle: FontStyle.italic));
        else {
          DateTime time =
          DateTime.tryParse(snap.data.data()['last seen'].toString());
          return Text(
            '${time.hour}:${time.minute}',
            style: TextStyle(fontStyle: FontStyle.italic),
          );
        }
      },
    );
  }

  User curUsr = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  SearchtoMessage(displayNamecurrentUser: displayName),
            ),
          );
        },
      ),
      appBar: AppBar(
        title: Text(
          "Messaging",
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          color: Colors.deepPurple,
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.deepPurple,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Scaffold(
          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("ChatRoom")
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('No internet Connection');
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                default:
                  print(snapshot.data.docs.length.toString());
                  return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, i) {
                      if (snapshot.data.docs[i]['users']
                          .contains(displayName)) {
                        getUserInfo(snapshot.data.docs[i] && snapshot.data.docs.length>1);
                        return FutureBuilder(
                          future: getUserInfo(snapshot.data.docs[i]),
                          builder: (context, snap) {
                            if (snap.hasData) {
                              print('func data ' + snapshot.data.toString());
                              String name =
                              getUserName(snapshot.data.docs[i]['users']);

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ConversationScreen(
                                          chatRoomID: snapshot.data.docs[i].id,
                                          displayName: displayName,
                                          enduser: name),
                                    ),
                                  );
                                },
                                child: Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          snap.data[0].toString()),
                                    ),
                                    title: Text(name),
                                    trailing: onlineStatus(snap.data[1]),
                                  ),
                                ),
                              );
                            } else
                              return Center(child: CircularProgressIndicator());
                          },
                        );
                      } else
                        return Container(height: MediaQuery.of(context).size.height*0.8,child: Center(child: Text("Search your friends and start texting!")));
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
