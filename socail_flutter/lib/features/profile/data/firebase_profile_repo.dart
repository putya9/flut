import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socail_flutter/features/profile/domain/entities/profile_user.dart';
import 'package:socail_flutter/features/profile/domain/repos/profile_repos.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  @override
  Future<ProfileUser?> fetchUserProfileByUID(String uid) async {
    try {
      final userDoc =
          await firebaseFirestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          final followers = List<String>.from(userData['followers'] ?? []);
          final following = List<String>.from(userData['following'] ?? []);
          return ProfileUser(
              bio: userData['bio'] ?? '',
              profileImageUrl: userData['profileImageUrl'].toString(),
              uid: uid,
              email: userData['email'],
              name: userData['name'],
              followers: followers,
              following: following);
        }
      }
      return null;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  @override
  Future<void> updateProfile(ProfileUser updatedProfile) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(updatedProfile.uid)
          .update({
        'bio': updatedProfile.bio,
        'profileImageUrl': updatedProfile.profileImageUrl
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
    try {
      final currentUser =
          await firebaseFirestore.collection('users').doc(currentUid).get();
      final targetUser =
          await firebaseFirestore.collection('users').doc(targetUid).get();
      if (currentUser.exists && targetUser.exists) {
        final currentUserData = currentUser.data();
        final targetUserData = targetUser.data();
        if (currentUserData != null && targetUserData != null) {
          final List<String> currentFollowing =
              List<String>.from(currentUserData['following'] ?? []);
          if (currentFollowing.contains(targetUid)) {
            await firebaseFirestore.collection('users').doc(currentUid).update({
              'following': FieldValue.arrayRemove([targetUid])
            });
            await firebaseFirestore.collection('users').doc(targetUid).update({
              'followers': FieldValue.arrayRemove([currentUid])
            });
          } else {
            await firebaseFirestore.collection('users').doc(currentUid).update({
              'following': FieldValue.arrayUnion([targetUid])
            });
            await firebaseFirestore.collection('users').doc(targetUid).update({
              'followers': FieldValue.arrayUnion([currentUid])
            });
          }
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
