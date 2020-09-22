import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'Otheruser/other_user.dart';

class CloudFirestoreSearch extends StatefulWidget {
  final displayNamecurrentUser;
  CloudFirestoreSearch({this.displayNamecurrentUser});
  @override
  _CloudFirestoreSearchState createState() => _CloudFirestoreSearchState(displayNamecurrentUser: displayNamecurrentUser);
}

class _CloudFirestoreSearchState extends State<CloudFirestoreSearch> {
  String fname = "";
  String lname = "";
  String searchKey;
  Stream streamQuery;
  final String displayNamecurrentUser;

  _CloudFirestoreSearchState({this.displayNamecurrentUser});


  @override
  Widget build(BuildContext context) {
    print(displayNamecurrentUser);
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
                  .where('displayName', isGreaterThanOrEqualTo: searchKey)
                  .where('displayName', isLessThan: searchKey +'z')
//                  .where('displayName', isGreaterThanOrEqualTo: searchKey.toUpperCase())
//                  .where('displayName', isGreaterThanOrEqualTo: searchKey.toLowerCase())
//                  .where('displayName', isLessThan: searchKey.toUpperCase() +'Z')
//                  .where('displayName', isLessThan: searchKey.toLowerCase() +'z')
                  .snapshots();
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (searchKey != "" && searchKey != null)?streamQuery
        : Firestore.instance.collection("users").snapshots(),
//        (fname != "" && fname != null)
//            ? Firestore.instance
//            .collection('users')
//            .where("searchKeywords", arrayContains: fname)
//            .snapshots()
//            : Firestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              DocumentSnapshot sd = snapshot.data.documents[index];
              searchKey = snapshot.data.documents[index]["displayName"];
              String photoUrl = snapshot.data.documents[index]["photoUrl"];
              String uid = snapshot.data.documents[index]["uid"];
              String displayName = snapshot.data.documents[index]["displayName"];
              print(displayName);
              return (searchKey!= null)?Card(
                child: Row(
                  children: <Widget>[

                    SizedBox(
                      width: 25,
                    ),

                        FlatButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OtherUserProfile(uid: uid,displayNamecurrentUser: displayNamecurrentUser,displayName: displayName)),
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