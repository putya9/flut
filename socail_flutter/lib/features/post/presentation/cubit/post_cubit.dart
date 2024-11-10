import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:socail_flutter/features/post/domain/entities/comment.dart';
import 'package:socail_flutter/features/post/domain/entities/post.dart';
import 'package:socail_flutter/features/post/domain/repos/post_repo.dart';
import 'package:socail_flutter/features/storage/domain/sotage_repo.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;
  PostCubit({required this.postRepo, required this.storageRepo})
      : super(PostsInitial());

  Future<void> createPost(Post post,
      {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;
    try {
      if (imagePath != null) {
        emit(PostsUploading());
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      } else if (imageBytes != null) {
        emit(PostsUploading());
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }
      final newPost = post.copyWitch(imageUrl: imageUrl);
      postRepo.createPost(newPost);
      fetchAllPosts();
    } catch (e) {
      emit(PostsError('Не удалось создать пост: $e'));
    }
  }

  Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError('Не удалось загрузить посты: $e'));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
    } catch (e) {
      emit(PostsError('Не удалось удалить поcт: $e'));
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostsError('Не удалось поставить лайк: $e'));
    }
  }

  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);
      await fetchAllPosts();
    } catch (e) {
      emit(PostsError('Не удалось оставить коментарий: $e'));
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);
      await fetchAllPosts();
    } catch (e) {
      emit(PostsError('Не удалось удалить коментарий: $e'));
    }
  }
}
