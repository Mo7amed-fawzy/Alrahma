import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrahma/core/funcs/init_and_load_databases.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeString = await DatabasesNames.themeMode?.getData('themeMode');

    switch (themeString) {
      case 'light':
        emit(ThemeMode.light);
        break;
      case 'dark':
        emit(ThemeMode.dark);
        break;
      default:
        emit(ThemeMode.system);
    }
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      emit(ThemeMode.dark);
      await DatabasesNames.themeMode?.setData('themeMode', 'dark');
    } else {
      emit(ThemeMode.light);
      await DatabasesNames.themeMode?.setData('themeMode', 'light');
    }
  }
}
