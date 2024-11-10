import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:socail_flutter/features/auth/domain/enties/app_user.dart';
import 'package:socail_flutter/features/auth/presentation/components/my_text_field.dart';
import 'package:socail_flutter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socail_flutter/features/post/domain/entities/comment.dart';
import 'package:socail_flutter/features/post/domain/entities/post.dart';
import 'package:socail_flutter/features/post/presentation/components/commet_tile.dart';
import 'package:socail_flutter/features/post/presentation/cubit/post_cubit.dart';
import 'package:socail_flutter/features/profile/domain/entities/profile_user.dart';
import 'package:socail_flutter/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:socail_flutter/features/profile/presentation/pages/profile_page.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  const PostTile(
      {super.key, required this.post, required this.onDeletePressed});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  bool isOwnPost = false;
  AppUser? currentUser;
  ProfileUser? postUser;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }

  @override
  void dispose() {
    super.dispose();
    commentTextController.dispose();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = widget.post.userId == currentUser!.uid;
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  void toogleLikePost() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });
    postCubit.toggleLike(widget.post.id, currentUser!.uid).catchError((error) {
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  final commentTextController = TextEditingController();
  void openNewCommentBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: MyTextField(
                  controller: commentTextController,
                  hintText: 'Коментарий',
                  obscureText: false),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Отмена')),
                TextButton(
                    onPressed: () {
                      addComment();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Отправить'))
              ],
            ));
  }

  void addComment() {
    final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: widget.post.id,
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: commentTextController.text,
        timestamp: DateTime.now());
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  void showOpthions() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Удалить запись?'),
              actions: [
                TextButton(
                    onPressed: () {
                      widget.onDeletePressed!();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Удалить')),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Отмена'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Container(
        color: Theme.of(context).colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(uid: widget.post.userId))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 5),
                    postUser?.profileImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: postUser!.profileImageUrl,
                            imageBuilder: (context, imageProvider) => Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover)),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.person),
                          )
                        : const Icon(
                            Icons.person,
                            size: 40,
                          ),
                    const SizedBox(width: 5),
                    Text(
                      widget.post.userName,
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (isOwnPost)
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: GestureDetector(
                            onTap: showOpthions,
                            child: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.primary,
                            )),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: CachedNetworkImage(
                  imageUrl: widget.post.imageUrl,
                  height: 430,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(
                    height: 430,
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Row(
                        children: [
                          GestureDetector(
                              onTap: () => toogleLikePost(),
                              child: Icon(
                                widget.post.likes.contains(currentUser!.uid)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    widget.post.likes.contains(currentUser!.uid)
                                        ? Colors.red
                                        : Theme.of(context).colorScheme.primary,
                              )),
                          Text(
                            (widget.post.likes.length).toString(),
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                        onTap: openNewCommentBox,
                        child: Icon(
                          Icons.comment,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                    Text(
                      (widget.post.comments.length).toString(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('dd.MM.yy').format(widget.post.timestamp),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Text(
                      widget.post.userName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.post.text,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    )
                  ],
                ),
              ),
              if (widget.post.comments.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Divider(
                    height: 0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              BlocBuilder<PostCubit, PostState>(builder: (context, state) {
                if (state is PostsLoaded) {
                  final post = state.posts
                      .firstWhere((post) => (post.id == widget.post.id));
                  if (post.comments.isNotEmpty) {
                    int showCommentsCount = post.comments.length;
                    return ListView.builder(
                        itemCount: showCommentsCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final comment = post.comments[index];
                          return CommetTile(
                            comment: comment,
                            post: widget.post,
                          );
                        });
                  }
                }
                if (state is PostsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is PostsError) {
                  return Center(
                    child: Text(state.error),
                  );
                } else {
                  return const SizedBox();
                }
              })
            ],
          ),
        ),
      ),
    );
  }
}
