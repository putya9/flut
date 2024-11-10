import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socail_flutter/features/search/domain/repo/search_repo.dart';
import 'package:socail_flutter/features/search/presentation/cubits/search_states.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo searchRepo;
  SearchCubit({required this.searchRepo}) : super(SearchInitial());
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }
    try {
      emit(SearchLoading());
      final users = await searchRepo.searchUser(query);
      emit(SearchLoaded(users));
    } catch (e) {
      emit(SearchError(error: 'Ошибка поиска: $e'));
    }
  }
}
