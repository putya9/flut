import 'package:socail_flutter/features/auth/domain/enties/app_user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profileImageUrl;
  final List<String> followers;
  final List<String> following;

  ProfileUser(
      {required this.bio,
      required this.profileImageUrl,
      required super.uid,
      required super.email,
      required super.name,
      required this.followers,
      required this.following});

  ProfileUser copyWithc(
      {String? newBio,
      String? newProfileImageUrl,
      List<String>? newFollowers,
      List<String>? newFollowing}) {
    return ProfileUser(
        bio: newBio ?? bio,
        profileImageUrl: newProfileImageUrl ?? profileImageUrl,
        uid: uid,
        email: email,
        name: name,
        followers: newFollowers ?? followers,
        following: newFollowing ?? following);
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'followers': followers,
      'following': following
    };
  }

  factory ProfileUser.fromJson(Map<String, dynamic> jsonUser) {
    return ProfileUser(
        uid: jsonUser['uid'],
        email: jsonUser['email'],
        name: jsonUser['name'],
        bio: jsonUser['bio'] ?? '',
        profileImageUrl: jsonUser['profileImageUrl'] ?? '',
        followers: List<String>.from(jsonUser['followers'] ?? []),
        following: List<String>.from(jsonUser['following'] ?? []));
  }
}
