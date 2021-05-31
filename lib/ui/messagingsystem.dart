import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:techstagram/ui/messagesearchlist.dart';
import 'searchlist.dart';
class ConversationPage extends StatefulWidget {
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
//  void _onHorizontalDrag(DragEndDetails details) {
//    if (details.primaryVelocity == 0)
//      // user have just tapped on screen (no dragging)
//      return;
//
//    if (details.primaryVelocity.compareTo(0) == -1) {
////      dispose();
//      return;
//    }
//    else {
//      Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 4)),
//      );
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
//      onHorizontalDragEnd: (DragEndDetails details) =>
//          _onHorizontalDrag(details),
      child: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.white,
//              appBar: ChatAppBar(), /
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
        body:

             Stack(children: <Widget>[
               Column(
                 children: <Widget>[
                  Expanded(child: SearchtoMessage()),
                  
        //     Align(
        //   alignment: Alignment.center,
        //   child: MaterialButton(
        //       onPressed: () {},
        //       child: Text(
        //         "working on messaging",
        //         style: TextStyle(
        //           color: Colors.purple,
        //           fontWeight: FontWeight.bold,
        //           fontSize: 15.0,
        //         ),
        //       )),
        // ),
                 ],
               ),
             ]
     )
      )),
    );
  }
}
