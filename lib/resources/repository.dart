import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/models/users.dart';
import 'package:techstagram/resources/firebase_provider.dart';

class Repository {

  final _firebaseProvider = FirebaseProvider();

  Future<void> addDataToDb(SingleUser user) => _firebaseProvider.addDataToDb(user);

  Future<User> signIn() => _firebaseProvider.signIn();

  Future<bool> authenticateUser(User user) => _firebaseProvider.authenticateUser(user);

  Future<User> getCurrentUser() => _firebaseProvider.getCurrentUser();

  Future<void> signOut() => _firebaseProvider.signOut();

  Future<String> uploadImageToStorage(File imageFile) => _firebaseProvider.uploadImageToStorage(imageFile);


  Future<UserData> retrieveUserDetails(User user) => _firebaseProvider.retrieveUserDetails(user);

  Future<List<DocumentSnapshot>> retrieveUserPosts(String userId) => _firebaseProvider.retrieveUserPosts(userId);

  Future<List<DocumentSnapshot>> fetchPostComments(DocumentReference reference) => _firebaseProvider.fetchPostCommentDetails(reference);

  Future<List<DocumentSnapshot>> fetchPostLikes(DocumentReference reference) => _firebaseProvider.fetchPostLikeDetails(reference);

  Future<bool> checkIfUserLikedOrNot(String userId, DocumentReference reference) => _firebaseProvider.checkIfUserLikedOrNot(userId, reference);

   Future<List<DocumentSnapshot>> retrievePosts(User user) => _firebaseProvider.retrievePosts(user);

  Future<List<String>> fetchAllUserNames(User user) => _firebaseProvider.fetchAllUserNames(user);

  Future<String> fetchUidBySearchedName(String name) => _firebaseProvider.fetchUidBySearchedName(name);

  Future<UserData> fetchUserDetailsById(String uid) => _firebaseProvider.fetchUserDetailsById(uid);

  Future<void> followUser({String currentUserId, String followingUserId}) => _firebaseProvider.followUser(currentUserId: currentUserId, followingUserId: followingUserId);

  Future<void> unFollowUser({String currentUserId, String followingUserId}) => _firebaseProvider.unFollowUser(currentUserId: currentUserId, followingUserId: followingUserId);

  Future<bool> checkIsFollowing(String name, String currentUserId) => _firebaseProvider.checkIsFollowing(name, currentUserId);

  Future<List<DocumentSnapshot>> fetchStats({String uid, String label}) => _firebaseProvider.fetchStats(uid: uid, label: label);

  Future<void> updatePhoto(String photoUrl, String uid) => _firebaseProvider.updatePhoto(photoUrl, uid);

  Future<void> updateDetails(String uid, String name, String bio, String email, String phone) => _firebaseProvider.updateDetails(uid, name, bio, email, phone);

  Future<List<String>> fetchUserNames(User user) => _firebaseProvider.fetchUserNames(user);

  Future<List<UserData>> fetchAllUsers(User user) => _firebaseProvider.fetchAllUsers(user);

  Future<List<DocumentSnapshot>> fetchFeed(User user) => _firebaseProvider.fetchFeed(user);

  Future<List<String>> fetchFollowingUids(User user) => _firebaseProvider.fetchFollowingUids(user);

  //Future<List<DocumentSnapshot>> retrievePostByUID(String uid) => _firebaseProvider.retrievePostByUID(uid);

}