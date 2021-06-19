import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'Otheruser/other_user.dart';

class FollowingList extends StatefulWidget {
  final displayNamecurrentUser;
  final uidX;
  FollowingList({this.displayNamecurrentUser, this.uidX});
  @override
  _FollowingList createState() => _FollowingList(
      displayNamecurrentUser: displayNamecurrentUser, uidX: uidX);
}

class _FollowingList extends State<FollowingList> {
  String fname = "";
  String lname = "";
  String searchKey;
  Stream<QuerySnapshot> streamQuery;
  final String displayNamecurrentUser;
  final String uidX;
  //String bandekiuid;

  _FollowingList({this.displayNamecurrentUser, this.uidX});

  //String uidf = FollowersList().uidX;
  @override
  Widget build(BuildContext context) {
    print("cv");
    print(uidX);
    print("434");
    return Scaffold(
      appBar: AppBar(
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
        title: Card(
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
                    .doc(uidX)
                    .collection('following')
                    .where('displayName', isGreaterThanOrEqualTo: searchKey)
                    .where('displayName', isLessThan: searchKey + 'z')
                    .snapshots();

                // getPostsUser(String uidX) async {
                //   return Firestore.instance.collection('users')
                //       .document(uidX)
                //       .collection('posts')
                //       .orderBy("timestamp", descending: true)
                //       .snapshots();
                //}
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (searchKey != "" && searchKey != null)
            ? streamQuery
            : FirebaseFirestore.instance
                .collection("users")
                .doc(uidX)
                .collection('following')
                .snapshots(),
//        (fname != "" && fname != null)
//            ? Firestore.instance
//            .collection('users')
//            .where("searchKeywords", arrayContains: fname)
//            .snapshots()
//            : Firestore.instance.collection("users").snapshots(),
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
                    DocumentSnapshot sd = snapshot.data.docs[index];
                    print(sd);
                    print("'are haoina");
                    searchKey = snapshot.data.docs[index]["followingname"];

                    var aja = snapshot.data.docs[index];

                    String photoUrl;
                    String uid;
                    String displayName;

                    // if (snapshot.data.docs[index].data().containsKey('photoUrl') == null) {
                    //   photoUrl = aja['photoUrl'];
                    //   print(photoUrl);
                    //
                    //   String uid = aja["uid"];
                    //   print(uid);
                    //
                    //   String displayName = aja["followingname"];
                    //   print(displayName);
                    //   // OwnerPhotourl =
                    //   // aja['OwnerPhotourl'];
                    //   // OwnerDescription = aja['OwnerDescription'];
                    // }

                    //snapshot.data.docs[index]["photoUrl"];

                    //bandekiuid = snapshot.data.documents[index]["uid"];

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
