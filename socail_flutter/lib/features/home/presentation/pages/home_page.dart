import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:socail_flutter/features/home/presentation/components/my_drawer.dart';
import 'package:socail_flutter/features/post/presentation/components/post_tile.dart';
import 'package:socail_flutter/features/post/presentation/cubit/post_cubit.dart';
import 'package:socail_flutter/features/post/presentation/pages/post_upload_page.dart';
import 'package:socail_flutter/responsive/constraide_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final postCubit = context.read<PostCubit>();
  @override
  void initState() {
    super.initState();
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return ConstraideScaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PostUploadPage())),
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: const MyDrawer(),
      body: BlocBuilder<PostCubit, PostState>(builder: (context, state) {
        if (state is PostsLoading && state is PostsUploading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is PostsLoaded) {
          final allPosts = state.posts;
          if (allPosts.isEmpty) {
            return const Center(
              child: Text('Посты не найдены'),
            );
          }
          return ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                final post = allPosts[index];
                return PostTile(
                  post: post,
                  onDeletePressed: () => deletePost(post.id),
                );
              });
        } else if (state is PostsError) {
          return Center(
            child: Text('Ошибка загрузки: ${state.error}'),
          );
        } else {
          return const SizedBox();
        }
      }),
    );
  }
}
