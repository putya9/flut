import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socail_flutter/features/post/domain/entities/comment.dart';
import 'package:socail_flutter/features/post/domain/entities/post.dart';
import 'package:socail_flutter/features/post/domain/repos/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference postCollection =
      FirebaseFirestore.instance.collection('posts');
  @override
  Future<void> createPost(Post post) async {
    try {
      await postCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception('error create post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await postCollection.doc(postId).delete();
    } catch (e) {
      throw Exception('error delete post: $e');
    }
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      final postSnapshot =
          await postCollection.orderBy('timestamp', descending: true).get();
      final List<Post> allPost = postSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return allPost;
    } catch (e) {
      throw Exception('Error fetching post: $e');
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try {
      final postSnapshot =
          await postCollection.where('userId', isEqualTo: userId).get();
      final userPosts = postSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return userPosts;
    } catch (e) {
      throw Exception('Error fetching post by userId: $e');
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      final postDoc = await postCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        final hasLiked = post.likes.contains(userId);
        if (hasLiked) {
          post.likes.remove(userId);
        } else {
          post.likes.add(userId);
        }
        await postCollection.doc(postId).update({'likes': post.likes});
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error toggle like: $e');
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      final postDoc = await postCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        post.comments.add(comment);
        await postCollection.doc(postId).update(
            {'comments': post.comments.map((c) => c.toJson()).toList()});
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error adding comment: $e');
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      final postDoc = await postCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        post.comments.removeWhere((c) => c.id == commentId);
        await postCollection.doc(postId).update(
            {'comments': post.comments.map((c) => c.toJson()).toList()});
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error deleting comment: $e');
    }
  }
}
