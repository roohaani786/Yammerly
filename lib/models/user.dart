//import 'package:cloud_firestore/cloud_firestore.dart';

class Datauser{
  final String uid;
  Datauser({this.uid});
}

class User {


   String uid;
   String email;
   String photoUrl;
   String displayName;
   int followers;
   int following;
   int posts;
   String bio;
   String link;
   String phone;
   String gender;
   String description;
   String work;
   String education;
   String currentCity;
   String homeTown;
   String relationship;


   User({this.uid, this.email, this.photoUrl, this.displayName, this.followers, this.following, this.bio, this.posts, this.phone,this.link, this.gender,
   this.work,this.education,this.currentCity,this.homeTown,this.relationship});

    Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['email'] = user.email;
    data['photoUrl'] = user.photoUrl;
    data['displayName'] = user.displayName;
    data['followers'] = user.followers;
    data['following'] = user.following;
    data['bio'] = user.bio;
    data['gender'] = user.gender;
    data['link'] = user.link;
    data['posts'] = user.posts;
    data['phone'] = user.phone;
    data['work'] = user.work;
    data['education'] = user.education;
    data['currentCity'] = user.currentCity;
    data['homeTown'] = user.homeTown;
    data['relationship'] = user.relationship;
    return data;
  }

  User.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.email = mapData['email'];
    this.photoUrl = mapData['photoUrl'];
    this.link = mapData['link'];
    this.gender = mapData['gender'];
    this.displayName = mapData['displayName'];
    this.followers = mapData['followers'];
    this.following = mapData['following'];
    this.bio = mapData['bio'];
    this.posts = mapData['posts'];
    this.phone = mapData['phone'];
    this.work = mapData['work'];
    this.education = mapData['education'];
    this.currentCity = mapData['currentCity'];
    this.homeTown = mapData['homeTown'];
    this.relationship = mapData['relationship'];
  }
}




