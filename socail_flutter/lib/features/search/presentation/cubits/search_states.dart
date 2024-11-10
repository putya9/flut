// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:socail_flutter/features/profile/domain/entities/profile_user.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<ProfileUser?> users;
  SearchLoaded(
    this.users,
  );
}

class SearchError extends SearchState {
  final String error;
  SearchError({
    required this.error,
  });
}
