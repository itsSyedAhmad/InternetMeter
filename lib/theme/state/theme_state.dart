import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode themeMode;

  ThemeState({required this.themeMode});
}

class ThemeInitial extends ThemeState {
  ThemeInitial() : super(themeMode: ThemeMode.system);
}