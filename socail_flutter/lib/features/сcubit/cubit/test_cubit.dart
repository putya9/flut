import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'test_state.dart';

class TestCubit extends Cubit<TestState> {
  TestCubit() : super(TestInitial());
  void testTaped() {
    try {
      emit(TestTaped());
    } catch (e) {
      throw Exception(e);
    }
  }
}
