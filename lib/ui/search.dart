//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';
//import 'package:firebase_database/firebase_database.dart';
//import 'package:firebase_database/ui/firebase_animated_list.dart';
//
//
//class Db extends StatefulWidget {
//  @override
//  HomeState createState() => HomeState();
//}
//
//class HomeState extends State<Db> {
//  List<Item> Remedios = List();
//  Item item;
//  DatabaseReference itemRef;
//  TextEditingController controller = new TextEditingController();
//  String filter;
//
//  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//  @override
//  void initState() {
//    super.initState();
//    item = Item("", "");
////    final FirebaseDatabase database = FirebaseDatabase.instance; //Rather then just writing FirebaseDatabase(), get the instance.
////    itemRef = Firestore.instance
//    itemRef.onChildAdded.listen(_onEntryAdded);
//    itemRef.onChildChanged.listen(_onEntryChanged);
//    controller.addListener(() {
//      setState(() {
//        filter = controller.text;
//      });
//    });
//  }
//
//  _onEntryAdded(Event event) {
//    setState(() {
//      Remedios.add(Item.fromSnapshot(event.snapshot));
//    });
//  }
//
//  _onEntryChanged(Event event) {
//    var old = Remedios.singleWhere((entry) {
//      return entry.key == event.snapshot.key;
//    });
//    setState(() {
//      Remedios[Remedios.indexOf(old)] = Item.fromSnapshot(event.snapshot);
//    });
//  }
//
//  void handleSubmit() {
//    final FormState form = formKey.currentState;
//
//    if (form.validate()) {
//      form.save();
//      form.reset();
//      itemRef.push().set(item.toJson());
//    }
//  }
//
//
//  @override
//  void dispose() {
//    controller.dispose();
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: new AppBar(
//        centerTitle: true,
//        backgroundColor: new Color(0xFFE1564B),
//      ),
//      resizeToAvoidBottomPadding: false,
//      body: Column(
//          children: <Widget>[
//      new TextField(
//      decoration: new InputDecoration(
//          labelText: "Type something"
//      ),
//      controller: controller,
//    ),
//    Flexible(
//    child: FirebaseAnimatedList(
//    query: itemRef,
//    itemBuilder: (BuildContext context, DataSnapshot snapshot,
//    Animation<double> animation, int index) {
//    return  Remedios[index].displayName.contains(filter) || Remedios[index].form.contains(filter) ? ListTile(
//    leading: Icon(Icons.message),
//    title: Text(Remedios[index].displayName),
//    subtitle: Text(Remedios[index].form),
//    ) : new Container();
//    },
//    ),
//    ),
//    ],
//    ),
//    );
//  }
//}
//
//class Item {
//  String key;
//  String form;
//  String displayName;
//
//  Item(this.form, this.displayName);
//
//  Item.fromSnapshot(DataSnapshot snapshot)
//      : key = snapshot.key,
//        form = snapshot.value["form"],
//        displayName = snapshot.value["displayName"];
//
//  toJson() {
//    return {
//      "form": form,
//      "displayName": displayName,
//    };
//  }
//}