part of 'test_cubit.dart';

@immutable
sealed class TestState {}

final class TestInitial extends TestState {}

final class TestTaped extends TestState {}
