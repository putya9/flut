import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socail_flutter/features/profile/presentation/components/user_tile.dart';
import 'package:socail_flutter/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:socail_flutter/responsive/constraide_scaffold.dart';

class FollowerPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;
  final void Function()? onBack;
  const FollowerPage(
      {super.key,
      required this.followers,
      required this.following,
      required this.onBack});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: ConstraideScaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.primary,
                )),
            bottom: TabBar(
                labelColor: Theme.of(context).colorScheme.inversePrimary,
                unselectedLabelColor: Theme.of(context).colorScheme.primary,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(
                    text: 'Подписчики',
                  ),
                  Tab(
                    text: 'Подписки',
                  )
                ]),
          ),
          body: TabBarView(children: [
            _buildUserList(followers, 'Подписчики не найдены', context),
            _buildUserList(following, 'Подписки не найдены', context)
          ]),
        ));
  }

  Widget _buildUserList(
      List<String> uids, String emptyMessage, BuildContext context) {
    return uids.isEmpty
        ? Center(
            child: Text(emptyMessage),
          )
        : ListView.builder(
            itemCount: uids.length,
            itemBuilder: (context, index) {
              final uid = uids[index];
              return FutureBuilder(
                  future: context.read<ProfileCubit>().getUserProfile(uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final user = snapshot.data!;
                      return UserTile(user: user);
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const ListTile(
                        title: Text('Загрузка....'),
                      );
                    } else {
                      return const ListTile(
                        title: Text('Пользователь не найден'),
                      );
                    }
                  });
            });
  }
}
