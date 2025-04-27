import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_internet_meter/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
      final int? themeIndex = await _getTheme();
    final loadedThemeMode =
        themeIndex != null ? ThemeMode.values[themeIndex] : ThemeMode.system;
    emit(ThemeState(themeMode: loadedThemeMode));
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    await _setTheme( themeMode);
    emit(ThemeState(themeMode: themeMode));
  }

  Future<void> setThemeToLight() async {
    await setTheme(ThemeMode.light);
  }

  Future<void> setThemeToDark() async {
    await setTheme(ThemeMode.dark);
  }

  Future<void> setThemeToSystem() async {
    await setTheme(ThemeMode.system);
  }

  static Future<int?> _getTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(themeKey);
  }


  static Future<bool> _setTheme(ThemeMode themeMode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(themeKey, themeMode.index);
  }

}