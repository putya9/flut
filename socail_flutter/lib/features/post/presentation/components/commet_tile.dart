import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socail_flutter/features/auth/domain/enties/app_user.dart';
import 'package:socail_flutter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socail_flutter/features/post/domain/entities/comment.dart';
import 'package:socail_flutter/features/post/domain/entities/post.dart';
import 'package:socail_flutter/features/post/presentation/cubit/post_cubit.dart';

class CommetTile extends StatefulWidget {
  final Comment comment;
  final Post post;
  const CommetTile({super.key, required this.comment, required this.post});

  @override
  State<CommetTile> createState() => _CommetTileState();
}

class _CommetTileState extends State<CommetTile> {
  AppUser? curentUser;
  bool isOwnPost = false;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    curentUser = authCubit.currentUser;
    isOwnPost = (widget.comment.userId == curentUser!.uid) ||
        (widget.post.userId == curentUser!.uid);
  }

  void showOpthions() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Удалить коментарий?'),
              actions: [
                TextButton(
                    onPressed: () {
                      context.read<PostCubit>().deleteComment(
                          widget.comment.postId, widget.comment.id);
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Text(
            '${widget.comment.userName}:',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary),
          ),
          const SizedBox(width: 5),
          Text(
            widget.comment.text,
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
          const Spacer(),
          if (isOwnPost)
            GestureDetector(
                onTap: showOpthions,
                child: Icon(
                  Icons.more_horiz,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ))
        ],
      ),
    );
  }
}
