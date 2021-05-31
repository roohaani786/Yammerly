import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'Otheruser/other_user.dart';

class SearchtoMessage extends StatefulWidget {
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
                    String photoUrl =
                        snapshot.data.docs[index]["photoURL"];
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              OtherUserProfile(
                                                  uid: uid,
                                                  displayNamecurrentUser:
                                                      displayNamecurrentUser,
                                                  displayName: displayName,
                                                  uidX: uidX)),
                                    );
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
