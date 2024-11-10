import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socail_flutter/features/auth/domain/enties/app_user.dart';
import 'package:socail_flutter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socail_flutter/features/post/presentation/components/post_tile.dart';
import 'package:socail_flutter/features/post/presentation/cubit/post_cubit.dart';
import 'package:socail_flutter/features/profile/presentation/components/bio_box.dart';
import 'package:socail_flutter/features/profile/presentation/components/follow_button.dart';
import 'package:socail_flutter/features/profile/presentation/components/profile_stats.dart';
import 'package:socail_flutter/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:socail_flutter/features/profile/presentation/cubits/profile_states.dart';
import 'package:socail_flutter/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:socail_flutter/features/profile/presentation/pages/follower_page.dart';
import 'package:socail_flutter/responsive/constraide_scaffold.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  late AppUser? currentUser = authCubit.currentUser;
  int postCount = 0;
  @override
  void initState() {
    super.initState();
    profileCubit.fetchUserProfileByUID(widget.uid);
  }

  void updatePage() {
    Navigator.pop(context);
    profileCubit.fetchUserProfileByUID(widget.uid);
  }

  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return;
    }
    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);
    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      } else {
        profileUser.followers.add(currentUser!.uid);
      }
    });
    profileCubit.toogleFollow(currentUser!.uid, widget.uid).catchError((error) {
      setState(() {
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        } else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = widget.uid == currentUser!.uid;
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final user = state.profileUser;
          return ConstraideScaffold(
            appBar: AppBar(
              title: Text(user.name),
              centerTitle: true,
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                if (isOwner)
                  IconButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                    user: user,
                                  ))),
                      icon: const Icon(Icons.edit))
              ],
            ),
            body: ListView(
              children: [
                Center(
                  child: Text(
                    user.email,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                CachedNetworkImage(
                  imageUrl: user.profileImageUrl,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  imageBuilder: (context, imageProvider) => Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover)),
                  ),
                ),
                const SizedBox(height: 25),
                ProfileStats(
                  postCount: postCount,
                  followerCount: user.followers.length,
                  followingCount: user.following.length,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FollowerPage(
                                followers: user.followers,
                                following: user.following,
                                onBack: updatePage,
                              ))),
                ),
                const SizedBox(height: 25),
                if (!isOwner)
                  FollowButton(
                      onPressed: followButtonPressed,
                      isFollowing: user.followers.contains(currentUser!.uid)),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Row(
                    children: [
                      Text(
                        'Bio',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                BioBox(text: user.bio),
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 25),
                  child: Row(
                    children: [
                      Text(
                        'Posts',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                BlocBuilder<PostCubit, PostState>(builder: (context, state) {
                  if (state is PostsLoaded) {
                    final userPosts = state.posts
                        .where((post) => post.userId == widget.uid)
                        .toList();
                    postCount = userPosts.length;

                    return ListView.builder(
                        itemCount: postCount,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final post = userPosts[index];
                          return PostTile(
                              post: post,
                              onDeletePressed: () => context
                                  .read<PostCubit>()
                                  .deletePost(post.id));
                        });
                  } else if (state is PostsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const Center(child: Text('Постов нет'));
                  }
                })
              ],
            ),
          );
        } else if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Text('Профиль не найден'),
            ),
          );
        }
      },
    );
  }
}
