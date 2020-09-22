import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CloudFirestoreSearch extends StatefulWidget {
  @override
  _CloudFirestoreSearchState createState() => _CloudFirestoreSearchState();
}

class _CloudFirestoreSearchState extends State<CloudFirestoreSearch> {
  String fname = "";
  String lname = "";
  String searchKey;
  Stream streamQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Card(
          child: TextField(
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Search...'),
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
              return (searchKey!= null)?Card(
                child: Row(
                  children: <Widget>[

                    SizedBox(
                      width: 25,
                    ),
                    GestureDetector(
                      onTap: (){

                      },
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
              ):Container();
            },
          );
        },
      ),
    );
  }

}