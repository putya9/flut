import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socail_flutter/features/%D1%81cubit/cubit/test_cubit.dart';
import 'package:socail_flutter/features/auth/data/firebase_auth_repo.dart';
import 'package:socail_flutter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socail_flutter/features/auth/presentation/pages/auth_page.dart';
import 'package:socail_flutter/features/home/presentation/pages/home_page.dart';
import 'package:socail_flutter/features/post/data/firebase_post_repo.dart';
import 'package:socail_flutter/features/post/presentation/cubit/post_cubit.dart';
import 'package:socail_flutter/features/profile/data/firebase_profile_repo.dart';
import 'package:socail_flutter/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:socail_flutter/features/search/data/firebase_search_repo.dart';
import 'package:socail_flutter/features/search/presentation/cubits/search_cubit.dart';
import 'package:socail_flutter/features/storage/data/firebase_storage_repo.dart';
import 'package:socail_flutter/themes/theme_cubit.dart';

class MainApp extends StatelessWidget {
  final firebaseAuthRepo = FirebaseAuthRepo();
  final firebaseProfileRepo = FirebaseProfileRepo();
  final firebasePostRepo = FirebasePostRepo();
  final firebaseStorageRepo = FirebaseStorageRepo();
  final firebaseSearchRepo = FirebaseSearchRepo();
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
              create: (context) =>
                  AuthCubit(authRepo: firebaseAuthRepo)..checkAuth()),
          BlocProvider<ProfileCubit>(
              create: (context) => ProfileCubit(
                  profileRepo: firebaseProfileRepo,
                  storageRepo: firebaseStorageRepo)),
          BlocProvider<PostCubit>(
              create: (context) => PostCubit(
                  postRepo: firebasePostRepo,
                  storageRepo: firebaseStorageRepo)),
          BlocProvider<SearchCubit>(
              create: (context) => SearchCubit(searchRepo: firebaseSearchRepo)),
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeData>(
            builder: (context, currentTheme) => MaterialApp(
                theme: currentTheme,
                debugShowCheckedModeBanner: false,
                home: BlocConsumer<AuthCubit, AuthState>(
                    builder: (context, state) {
                  if (state is Unauthenticated) {
                    return const AuthPage();
                  }
                  if (state is Authenticated) {
                    return const HomePage();
                  } else {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                }, listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(state.message)));
                  }
                }))));
  }
}
