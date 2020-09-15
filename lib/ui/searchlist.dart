import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';

SearchBar searchBar;
GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class DisplayCourse extends StatefulWidget {
  @override
  _DisplayCourseState createState() => new _DisplayCourseState();
}

AppBar _buildAppBar(BuildContext context) {
  return new AppBar(
    title: new Text("FIREBASE QUERY"),
    centerTitle: true,
    actions: <Widget>[
      searchBar.getSearchAction(context),
    ],
  );
}

class _DisplayCourseState extends State<DisplayCourse> {
  String _queryText;

  _DisplayCourseState() {
    searchBar = new SearchBar(
      onSubmitted: onSubmitted,
      inBar: true,
      buildDefaultAppBar: _buildAppBar,
      setState: setState,
    );
  }

  void onSubmitted(String value) {
    setState(() {
      _queryText = value;
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text('You have Searched something!'),
        backgroundColor: Colors.yellow,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: searchBar.build(context),
      backgroundColor: Colors.red,
      body: _fireSearch(_queryText),
    );
  }
}

Widget _fireSearch(String queryText) {
  return new StreamBuilder(
    stream: Firestore.instance
        .collection('users')
        .where('displayName', isEqualTo: queryText)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return new Text('Loading...');
      return new ListView.builder(
        itemCount: snapshot.data.documents.length,
        itemBuilder: (context, index) =>
            _buildListItem(snapshot.data.documents[index]),
      );
    },
  );
}

Widget _buildListItem(DocumentSnapshot document) {
  return new ListTile(
    title: Text(document['title'].toString(),style: TextStyle(
      color: Colors.black,
    ),),
   subtitle: document['subtitle'],
  );
}