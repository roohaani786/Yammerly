import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techstagram/ui/Otheruser/other_user.dart';

import 'other_user.dart';

class OtherFollowersList extends StatefulWidget {
  final displayName;
  final uid;
  final displayNamecurrentUser;
  final uidX;
  OtherFollowersList({this.displayName,this.uid,this.displayNamecurrentUser,this.uidX});
  @override
  _OtherFollowersList createState() => _OtherFollowersList(displayName: displayName,uid: uid,displayNamecurrentUser: displayNamecurrentUser,uidX: uidX);
}

class _OtherFollowersList extends State<OtherFollowersList> {
  String fname = "";
  String lname = "";
  String searchKey;
  Stream streamQuery;
  final String displayName;
  final String uid;
  final String displayNamecurrentUser;
  final String uidX;

  //String bandekiuid;

  _OtherFollowersList({this.displayName,this.uid,this.displayNamecurrentUser,this.uidX});

  //String uidf = FollowersList().uidX;
  @override
  Widget build(BuildContext context) {
    print("meme");
    print(uidX);
    print("434");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          color: Colors.deepPurple,
          icon: Icon(Icons.arrow_back_ios,color: Colors.deepPurple,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Card(
          color: Colors.white,
          child: TextField(
            decoration: InputDecoration(
//                prefixIcon: Icon(Icons.search,color: Colors.white,),
                hintText: ' Search...',hintStyle: TextStyle(
              color: Colors.black,
            )),
            onChanged: (val) {
              setState(() {
//                fname = val;
                searchKey = val;
                streamQuery = Firestore.instance.collection('users')
                    .document(uidX).collection('followers')
                    .where('displayName', isGreaterThanOrEqualTo: searchKey)
                    .where('displayName', isLessThan: searchKey +'z')
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
        stream: (searchKey != "" && searchKey != null)?streamQuery
            : Firestore.instance
            .collection("users")
            .document(uid)
            .collection('followers')
            .snapshots(),
//        (fname != "" && fname != null)
//            ? Firestore.instance
//            .collection('users')
//            .where("searchKeywords", arrayContains: fname)
//            .snapshots()
//            : Firestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(child: Container(
              decoration:  BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/profileedit.png'),
                  fit: BoxFit.cover,
                ),
                shape: BoxShape.circle,
              ),child: CircularProgressIndicator()))
              : ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot sd = snapshot.data.docs[index];
              searchKey = snapshot.data.docs[index]["followername"];
              String photoUrl = snapshot.data.docs[index]["photoUrl"];
              String uid = snapshot.data.docs[index]["uid"];
              String displayName = snapshot.data.docs[index]["followername"];
              return (searchKey!= null)?Card(
                child: Row(
                  children: <Widget>[

                    SizedBox(
                      width: 25,
                    ),

                    TextButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OtherUserProfile(uid: uid,displayNamecurrentUser: displayNamecurrentUser,displayName: displayName, uidX: uidX)),
                        );
                      },
                      child: Row(
                        children: [
                          (photoUrl!=null)?CircleAvatar(
                            radius: 20,
                            backgroundImage:
                            NetworkImage(photoUrl),
                            backgroundColor: Colors.transparent,
                          ): CircleAvatar(
                            radius: 20,
                            child: IconButton(icon:
                            Icon(FontAwesomeIcons.userCircle,
                              color: Colors.deepPurple,), onPressed: null),
                            backgroundColor: Colors.transparent,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
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
              ):Container();
            },
          );
        },
      ),
    );
  }

}