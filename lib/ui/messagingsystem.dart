import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  getUserInfo(dynamic doc) async {
    String userName = getUserName(doc['users']);
    String pic = '';
    print('userName fetched ' + userName);
    print('pre test fetch name ' + userName);
    var res = await FirebaseFirestore.instance
        .collection("users")
        .where("displayName", isEqualTo: userName)
        .get();
    //     .then((value) {
    //   value.docs.forEach((result) {
    //     pic = result.data()['photoURL'];
    //   });
    // });
    pic = res.docs
        .where((element) => element.data()['displayName'] == userName)
        .first['photoURL'];
    print('booy' + pic);
    return pic;
  }

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
            stream:
                FirebaseFirestore.instance.collection("ChatRoom").snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('No internet Coneection');
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                default:
                  return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, i) {
                      if (snapshot.data.docs[i]['users']
                          .contains(displayName)) {
                        getUserInfo(snapshot.data.docs[i]);
                        return FutureBuilder(
                          future: getUserInfo(snapshot.data.docs[i]),
                          builder: (context, snap) {
                            //  switch (snapshot.data.toString()) {
                            //       case '':
                            //         return CircularProgressIndicator();
                            //         default:
                            //          print('func data ' + snapshot.data);
                            return Card(
                              child: ListTile(
                                title: Text(getUserName(
                                    snapshot.data.docs[i]['users'])),
                              ),
                            );
                            //      }
                          },
                        );
                      } else
                        return Container();
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
