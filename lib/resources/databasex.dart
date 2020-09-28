import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techstagram/models/users.dart';

class DatabaseServiceX {
  final String uid;

  DatabaseServiceX({this.uid});

  getUserByUsername(String displayName) async {
    return Firestore.instance
        .collection('users')
        .where("displayName", isGreaterThanOrEqualTo: displayName)
        .getDocuments();
  }

  final CollectionReference wiggleCollection =
  Firestore.instance.collection('users');

  Stream<UserData> get userData {
    return wiggleCollection
        .document(uid)
        .snapshots()
        .map(_userDataFromSnapshot);
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
        email: snapshot.data['email'],
//        block: snapshot.data['block'],
        bio: snapshot.data['bio'],
        displayName: snapshot.data['name'],
        gender: snapshot.data['gender'] ?? '');
//        nickname: snapshot.data['nickname'],
//        isAnonymous: snapshot.data['isAnonymous'],
//        anonBio: snapshot.data['anonBio'] ?? '',
//        anonInterest: snapshot.data['anonInterest'] ?? '',
//        anonDp: snapshot.data['anonDp'] ?? '',
//        fame: snapshot.data['fame'] ?? 0,
//        media: snapshot.data['media'] ?? '',
//        course: snapshot.data['course'] ?? '',
//        playlist: snapshot.data['playlist'] ?? '',
//        accoms: snapshot.data['accoms'] ?? '');
  }
}