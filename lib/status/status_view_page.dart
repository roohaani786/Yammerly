import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:techstagram/status/status_model.dart';

class StatusViewScreen extends StatefulWidget {
  const StatusViewScreen({this.id});
  final String id;

  @override
  _StatusViewScreenState createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen> {
  final _storyController = StoryController();
  final controller = StoryController();

  @override
  Widget build(BuildContext context) {
    var stream = FirebaseFirestore.instance
        .collection("story")
        .doc(widget.id)
        .collection("uploaded status")
        .snapshots();

    List<Status> statusList = [];
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

    final controller = StoryController();
    final List<StoryItem> storyItems = [];
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

    return StreamBuilder(
      stream: stream,
      builder: (BuildContext ctx, snapShot) {
        switch (snapShot.connectionState) {
          case ConnectionState.none:
            return Center(child: Text("nothing to show"));
          case ConnectionState.waiting:
            return Center(child: Text("waiting"));
          default:
            if (snapShot.hasData) {
              for (int i = 0; i < snapShot.data.docs.length; i++) {
                addData(snapShot.data.docs[i]);
                addStoryItem();
                return Material(
                  child: StoryView(
                    storyItems: storyItems,
                    controller: controller,
                    inline: false,
                    onComplete: () {
                      Navigator.of(context).pop();
                    },
                  ),
                );
              }
            }
        }
      },
    );
  }
}

class StatusView extends StatelessWidget {
  final _storyController = StoryController();
  @override
  Widget build(BuildContext context) {
    final controller = StoryController();
    final List<StoryItem> storyItems = [];
    for (int i = 0; i < StatusList.statusList.length; i++) {
      if (StatusList.statusList[i].type == StatusType.text)
        storyItems.add(
          StoryItem.text(
              title: StatusList.statusList[i].data,
              backgroundColor: Colors.blue),
        );

      if (StatusList.statusList[i].type == StatusType.image)
        storyItems.add(
          StoryItem.pageImage(
              url: StatusList.statusList[i].data,
              controller: _storyController,
              imageFit: BoxFit.contain),
        );
    }

    return Material(
      child: StoryView(
        storyItems: storyItems,
        controller: controller,
        inline: false,
        onComplete: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
