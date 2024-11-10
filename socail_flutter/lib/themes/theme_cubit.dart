import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socail_flutter/themes/dark_mode.dart';
import 'package:socail_flutter/themes/light_mode.dart';

class ThemeCubit extends Cubit<ThemeData> {
  bool _isDarkMode = false;
  ThemeCubit() : super(lightMode);
  bool get isDarkMode => _isDarkMode;
  void toogleTheme() {
    _isDarkMode = !isDarkMode;
    if (isDarkMode) {
      emit(darkMode);
    } else {
      emit(lightMode);
    }
  }
}
