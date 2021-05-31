import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String id;
  final String authorId;
  final Timestamp timeEnd, timeStart;
  final String imageUrl;
  final Map<dynamic, dynamic> views;
  final String location;
  final String linkUrl, filter;
  final int duration;
  final String caption;

  Story(
      {this.id,
      this.authorId,
      this.timeEnd,
      this.timeStart,
      this.duration,
      this.imageUrl,
      this.filter,
      this.linkUrl,
      this.caption,
      this.views,
      this.location});

    factory Story.fromDoc(DocumentSnapshot doc) {
      return Story(
        id: doc.id,
        timeEnd: doc['timeEnd'],
        timeStart: doc['timeStart'],
        authorId: doc['authodId'],
        imageUrl: doc['imageUrl'],
        caption: doc['caption'],
        views: doc['views'],
        location: doc['location'],
        filter: doc['filter'],
        linkUrl: doc['linkUrl'] ?? '',
        duration: doc['duration'] ?? 10,
      );
  }
}
