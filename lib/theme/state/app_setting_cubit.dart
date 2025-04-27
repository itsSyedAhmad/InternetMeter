import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_internet_meter/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_setting_state.dart';

class AppSettingCubit extends Cubit<AppSetttingState> {
  AppSettingCubit() : super(SettingInitial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final int? themeIndex = await _getTheme();
    final int? notificationPreferenceIndex = await _getNotificationPreference();
    final int? speedIndicatorTypeIndex = await _getSpeedIndicatorType();
    final int? speedUnitIndex = await _getSpeedUnit();

    emit(
      state.copyWith(
        themeMode:
            themeIndex != null
                ? ThemeMode.values[themeIndex]
                : ThemeMode.system,
        notificationPreference:
            notificationPreferenceIndex != null
                ? NotificationPreference.values[notificationPreferenceIndex]
                : NotificationPreference.always,
        speedIndicatorType:
            speedIndicatorTypeIndex != null
                ? SpeedIndicatorType.values[speedIndicatorTypeIndex]
                : SpeedIndicatorType.onlyDownloadSpeed,
        speedUnit:
            speedUnitIndex != null
                ? SpeedUnit.values[speedUnitIndex]
                : SpeedUnit.bytes,
      ),
    );
    FlutterForegroundTask.sendDataToTask({
      "notificationPreference":
          notificationPreferenceIndex != null
              ? NotificationPreference.values[notificationPreferenceIndex]
                  .toString()
              : NotificationPreference.always.toString(),
    });
    //
    FlutterForegroundTask.sendDataToTask({
      "speedIndicatorType":
          speedIndicatorTypeIndex != null
              ? SpeedIndicatorType.values[speedIndicatorTypeIndex].toString()
              : SpeedIndicatorType.onlyDownloadSpeed.toString(),
    });
    FlutterForegroundTask.sendDataToTask({
      "speedUnit":
          speedUnitIndex != null
              ? SpeedUnit.values[speedUnitIndex].toString()
              : SpeedUnit.bytes.toString(),
    });
  }

  // Setters
  Future<void> setTheme(ThemeMode themeMode) async {
    await _setTheme(themeMode);
    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> setNotificationPreference(
    NotificationPreference notificationPreference,
  ) async {
    await _setNotificationPreference(notificationPreference);
    emit(state.copyWith(notificationPreference: notificationPreference));

    FlutterForegroundTask.sendDataToTask({
      "notificationPreference": notificationPreference.toString(),
    });
  }

  Future<void> setSpeedIndicatorType(
    SpeedIndicatorType speedIndicatorType,
  ) async {
    await _setSpeedIndicatorType(speedIndicatorType);
    emit(state.copyWith(speedIndicatorType: speedIndicatorType));
    FlutterForegroundTask.sendDataToTask({
      "speedIndicatorType": speedIndicatorType.toString(),
    });
  }

  Future<void> setSpeedUnit(SpeedUnit speedUnit) async {
    await _setSpeedUnit(speedUnit);
    emit(state.copyWith(speedUnit: speedUnit));
    FlutterForegroundTask.sendDataToTask({"speedUnit": speedUnit.toString()});
  }

  // Getters (private)
  static Future<int?> _getTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(themeKey);
  }

  static Future<int?> _getNotificationPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(notificationPreferenceKey);
  }

  static Future<int?> _getSpeedIndicatorType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(speedIndicatorTypeKey);
  }

  static Future<int?> _getSpeedUnit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(speedUnitKey);
  }

  // Setters (private)
  static Future<bool> _setTheme(ThemeMode themeMode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(themeKey, themeMode.index);
  }

  static Future<bool> _setNotificationPreference(
    NotificationPreference notificationPreference,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(
      notificationPreferenceKey,
      notificationPreference.index,
    );
  }

  static Future<bool> _setSpeedIndicatorType(
    SpeedIndicatorType speedIndicatorType,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(speedIndicatorTypeKey, speedIndicatorType.index);
  }

  static Future<bool> _setSpeedUnit(SpeedUnit speedUnit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(speedUnitKey, speedUnit.index);
  }
}
