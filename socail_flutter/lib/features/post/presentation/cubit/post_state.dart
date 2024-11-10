part of 'post_cubit.dart';

@immutable
sealed class PostState {}

final class PostsInitial extends PostState {}

final class PostsLoading extends PostState {}

final class PostsUploading extends PostState {}

final class PostsError extends PostState {
  final String error;
  PostsError(this.error);
}

final class PostsLoaded extends PostState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}
