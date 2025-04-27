import 'package:flutter/material.dart';

class AppSetttingState {
  final ThemeMode themeMode;
  final NotificationPreference notificationPreference;
  final SpeedIndicatorType speedIndicatorType;
  final SpeedUnit speedUnit;

  AppSetttingState({
    required this.themeMode,
    required this.notificationPreference,
    required this.speedIndicatorType,
    required this.speedUnit,
  });

  // ✅ Here's the copyWith method
  AppSetttingState copyWith({
    ThemeMode? themeMode,
    NotificationPreference? notificationPreference,
    SpeedIndicatorType? speedIndicatorType,
    SpeedUnit? speedUnit,
  }) {
    return AppSetttingState(
      themeMode: themeMode ?? this.themeMode,
      notificationPreference: notificationPreference ?? this.notificationPreference,
      speedIndicatorType: speedIndicatorType ?? this.speedIndicatorType,
      speedUnit: speedUnit ?? this.speedUnit,
    );
  }
}

class SettingInitial extends AppSetttingState {
  SettingInitial()
      : super(
          themeMode: ThemeMode.system,
          notificationPreference: NotificationPreference.always,
          speedIndicatorType: SpeedIndicatorType.onlyDownloadSpeed,
          speedUnit: SpeedUnit.bytes,
        );
}

enum NotificationPreference { always, onlyWhenInternetIsConnected }
enum SpeedIndicatorType { onlyDownloadSpeed, dowloadAndUploadBoth }
enum SpeedUnit { bytes, bites }
extension NotificationPreferenceExtension on NotificationPreference {
  static NotificationPreference fromString(String value) {
    switch (value) {
      case 'NotificationPreference.always':
        return NotificationPreference.always;
      case 'NotificationPreference.onlyWhenInternetIsConnected':
        return NotificationPreference.onlyWhenInternetIsConnected;
      default:
        throw Exception('Invalid NotificationPreference value');
    }
  }
}

extension SpeedIndicatorTypeExtension on SpeedIndicatorType {
  static SpeedIndicatorType fromString(String value) {
    switch (value) {
      case 'SpeedIndicatorType.onlyDownloadSpeed':
        return SpeedIndicatorType.onlyDownloadSpeed;
      case 'SpeedIndicatorType.dowloadAndUploadBoth':
        return SpeedIndicatorType.dowloadAndUploadBoth;
      default:
        throw Exception('Invalid SpeedIndicatorType value');
    }
  }
}

extension SpeedUnitExtension on SpeedUnit {
  static SpeedUnit fromString(String value) {
    switch (value) {
      case 'SpeedUnit.bytes':
        return SpeedUnit.bytes;
      case 'SpeedUnit.bites':
        return SpeedUnit.bites;
      default:
        throw Exception('Invalid SpeedUnit value');
    }
  }
}
