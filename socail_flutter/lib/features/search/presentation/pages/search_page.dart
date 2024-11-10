import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socail_flutter/features/auth/presentation/components/my_text_field.dart';
import 'package:socail_flutter/features/profile/presentation/components/user_tile.dart';
import 'package:socail_flutter/features/search/presentation/cubits/search_cubit.dart';
import 'package:socail_flutter/features/search/presentation/cubits/search_states.dart';
import 'package:socail_flutter/responsive/constraide_scaffold.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  late final searchCubit = context.read<SearchCubit>();
  void onSearchChanged() {
    final query = searchController.text;
    searchCubit.searchUsers(query);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstraideScaffold(
      appBar: AppBar(
          title: TextField(
        controller: searchController,
        decoration: InputDecoration(
            hintText: 'Поиск',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary)),
      )),
      body: BlocBuilder<SearchCubit, SearchState>(builder: (context, state) {
        if (state is SearchLoaded) {
          if (state.users.isEmpty) {
            return const Center(
              child: Text('Пользователи не найдены'),
            );
          }
          return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return UserTile(user: user!);
              });
        } else if (state is SearchLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is SearchError) {
          return Center(
            child: Text('Ошибка поиск: ${state.error}'),
          );
        } else {
          return const Center(
            child: Text('Начни искать друзей'),
          );
        }
      }),
    );
  }
}
