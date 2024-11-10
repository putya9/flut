import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socail_flutter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socail_flutter/features/home/presentation/components/my_drawer_tile.dart';
import 'package:socail_flutter/features/profile/presentation/pages/profile_page.dart';
import 'package:socail_flutter/features/search/presentation/pages/search_page.dart';
import 'package:socail_flutter/features/settings/pages/setting_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 25),
                child: Icon(
                  Icons.person,
                  size: 80,
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.primary,
              ),
              MyDrawerTile(
                title: 'H O M E',
                icon: Icons.home,
                onTap: () => Navigator.of(context).pop(),
              ),
              MyDrawerTile(
                title: 'P R O F I L E',
                icon: Icons.person,
                onTap: () {
                  Navigator.of(context).pop();
                  final user = context.read<AuthCubit>().currentUser;
                  String? uid = user!.uid;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(uid: uid)));
                },
              ),
              MyDrawerTile(
                title: 'S E A R C H',
                icon: Icons.search,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchPage())),
              ),
              MyDrawerTile(
                title: 'S E T T I N G S',
                icon: Icons.settings,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingPage())),
              ),
              const Spacer(),
              MyDrawerTile(
                  title: 'L O G O U T',
                  icon: Icons.logout,
                  onTap: () => context.read<AuthCubit>().logout())
            ],
          ),
        ),
      ),
    );
  }
}
