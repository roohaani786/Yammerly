import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:story_view/story_view.dart';
import 'package:techstagram/status/model/status_model.dart';

class StatusViewScreen extends StatefulWidget {
  const StatusViewScreen({this.id, this.myStatus});
  final String id;
  final bool myStatus;
  @override
  _StatusViewScreenState createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen> {
  final _storyController = StoryController();
  final controller = StoryController();

  @override
  Widget build(BuildContext context) {
    List<Status> statusList = [];
    List<StoryItem> storyItems = [];
    final controller = StoryController();

    void addData(dynamic doc) {
      var type;
      final data = doc["data"];
      var caption;
      switch (doc["type"]) {
        case 'text':
          type = StatusType.text;
          statusList.add(Status(data: data, type: type));
          break;
        case 'image':
          type = StatusType.image;
          caption = doc["caption"];
          statusList.add(Status(data: data, type: type, caption: caption));
          break;
      }
    }

    getData() async {
      await FirebaseFirestore.instance
          .collection("story")
          .doc(widget.id)
          .collection("uploaded status")
          .snapshots()
          .forEach((element) {
        element.docs.forEach((element) {
          addData(element.data());
        });
      });
    }

    void addStoryItem() {
      for (int i = 0; i < statusList.length; i++) {
        if (statusList[i].type == StatusType.text)
          storyItems.add(
            StoryItem.text(
                title: statusList[i].data, backgroundColor: Colors.blue),
          );

        if (statusList[i].type == StatusType.image)
          storyItems.add(
            StoryItem.pageImage(
                caption: statusList[i].caption,
                url: statusList[i].data,
                controller: _storyController,
                imageFit: BoxFit.contain),
          );
      }
    }

    int views = 0;
    FirebaseFirestore.instance
        .collection("story")
        .doc(widget.id)
        .collection("viewers")
        .get()
        .then((value) => views = value.size);

    User currUser = FirebaseAuth.instance.currentUser;
    var fbRef = FirebaseFirestore.instance.collection("story");

    usrViewed() {
      Status().addUserData();
      fbRef
          .doc(currUser.email)
          .collection("viewed")
          .doc(widget.id)
          .set({'story': widget.id});
    }

    uploaderView() {
      fbRef
          .doc(widget.id.toString())
          .collection("viewers")
          .doc(currUser.email.toString())
          .set({'viewer': currUser.email});
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('story')
            .doc(widget.id)
            .collection('uploaded status')
            .snapshots(),
        builder: (BuildContext ctx, snapShot) {
          print(getData());
          switch (snapShot.connectionState) {
            case ConnectionState.none:
              return Center(child: Text("nothing to show"));
            case ConnectionState.waiting:
              return Center(child: Text('waiting'));
            default:
              if (snapShot.hasData) {
                getData();
                addStoryItem();
                return Material(
                  child: StoryView(
                    storyItems: storyItems,
                    controller: controller,
                    onVerticalSwipeComplete: (direction) {
                      if (widget.myStatus && direction == Direction.up)
                        Alert(
                            context: context,
                            title: "Views : $views",
                            buttons: []).show();
                      if (direction == Direction.down)
                        Navigator.of(context).pop();
                    },
                    inline: false,
                    onComplete: () {
                      usrViewed();
                      uploaderView();
                      Navigator.of(context).pop();
                    },
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
