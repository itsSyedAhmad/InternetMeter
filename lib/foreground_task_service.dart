import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_internet_meter/data_usage.dart';
import 'package:flutter_internet_meter/storage_service.dart';
import 'package:flutter_internet_meter/text_service.dart';
import 'package:flutter_internet_meter/theme/state/app_setting_cubit.dart';
import 'package:flutter_internet_meter/theme/state/app_setting_state.dart';

class SpeedMonitorService {
  static final SpeedMonitorService _instance = SpeedMonitorService._internal();

  factory SpeedMonitorService() {
    return _instance;
  }

  SpeedMonitorService._internal();

  late Timer timer;

  bool foregroundTaskRunningAlready = false;

  static const _channel = MethodChannel(
    "com.example.flutter_internet_meter/speed_icon",
  );

  //
  Future<void> startForegroundService({required BuildContext ctc}) async {
    bool isConnected = false;

    timer = Timer.periodic(Duration(seconds: 1), (_) async {
      try {
        isConnected = await _channel.invokeMethod('isInternetConnected');
      } catch (e) {
        debugPrint(e.toString());
      }

      NotificationPreference notificationPreference =
          ctc.read<AppSettingCubit>().state.notificationPreference;
      if (notificationPreference ==
              NotificationPreference.onlyWhenInternetIsConnected &&
          isConnected == false) {
        foregroundTaskRunningAlready = false;
        FlutterForegroundTask.stopService();
      } else {
        if (!foregroundTaskRunningAlready) {
          init();
        }
      }
    });
  }

  Future<void> init() async {
    foregroundTaskRunningAlready = true;
    _initializeForegroundTask();

    // Start the foreground service with notification and callback
    await FlutterForegroundTask.startService(
      notificationTitle: 'Speed Monitor Running',
      notificationText: 'Monitoring speed in background...',
      callback: startCallback,
    );
    FlutterForegroundTask.initCommunicationPort();

    FlutterForegroundTask.addTaskDataCallback((data) {
      // ignore: unused_local_variable
      var resultMap = data as Map<Object?, Object?>;

      List<DataUsageModel> usageList =
          (data["values"] as List)
              .map((e) => DataUsageModel.fromMap(e as Map<String, dynamic>))
              .toList();

      DataUsageStorageService.instance.writeToMainBox(usageList);
    });
  }

  // Initialize the foreground task
  void _initializeForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'speed_monitor_channel',
        channelName: 'Speed Monitor Service',
        channelDescription: 'Shows internet speed even when app is closed',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.MIN,
        visibility: NotificationVisibility.VISIBILITY_PRIVATE
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: true,
        allowWakeLock: true,
      ),
    );
  }
}

// Entry point for the callback function in the foreground task
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(NetworkSpeedTaskHandler());
}

class NetworkSpeedTaskHandler extends TaskHandler {
  //static double currentKbps = 0;
  int i = 0;
  bool hasInitialized = false;
  bool isWiFi = false;
  double totalSpeed = 0;
  double downloadSpeedInKbps = 0;
  double uploadSpeedInKbps = 0;
  //temporary bool value
  NotificationPreference notificationPreference = NotificationPreference.always;
  SpeedIndicatorType speedIndicatorType = SpeedIndicatorType.onlyDownloadSpeed;
  SpeedUnit speedUnit = SpeedUnit.bytes;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter t) async {
    await DataUsageStorageService.instance.initIsolateBox();
    hasInitialized = true;
    // Initialization code if needed (like getting initial byte count)
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _checkSpeedAndNotify();
  }

  @override
  void onReceiveData(Object data) {
    // ignore: unused_local_variable
    var resultMap = data as Map<Object?, Object?>;
    if (data["notificationPreference"] != null) {
      notificationPreference = NotificationPreferenceExtension.fromString(
        data["notificationPreference"] as String,
      );
    } else if (data["speedIndicatorType"] != null) {
      speedIndicatorType = SpeedIndicatorTypeExtension.fromString(
        data["speedIndicatorType"] as String,
      );
    } else if (data["speedUnit"] != null) {
      speedUnit = SpeedUnitExtension.fromString(data["speedUnit"] as String);
    }
  }

  Future<void> _checkSpeedAndNotify() async {
    if (hasInitialized) {
      //these values will always be in Bytes and use to calculate data usage.

      bool shouldShowDownloadSpeedOnly =
          speedIndicatorType == SpeedIndicatorType.onlyDownloadSpeed;

      var resultMap = await FlutterForegroundTask.getSpeed();

      if (i != 0) {
        totalSpeed = resultMap["kbps"] as double;
        downloadSpeedInKbps = resultMap["rxKBps"] as double;
        uploadSpeedInKbps = resultMap["txKBps"] as double;
        isWiFi = resultMap["isWiFi"] as bool;
      }
      i++;

      final todayUsageBlock =
          DataUsageStorageService.instance.getTodayUsageFromIsolateBox();
      final todayWifiUsage = todayUsageBlock.wifi;
      final todayMobileUsage = todayUsageBlock.mobile;
      //Ui
      final curSpeedText = TextService().formatSpeed(
        shouldShowDownloadSpeedOnly
            ? (downloadSpeedInKbps.round())
            : (totalSpeed.round()),
        speedUnit == SpeedUnit.bites,
      );
      final curRxSpeedText = TextService().formatSpeed(
        downloadSpeedInKbps.round(),
        speedUnit == SpeedUnit.bites,
        test: true,
      );
      final curTxSpeedText = TextService().formatSpeed(
        uploadSpeedInKbps.round(),
        speedUnit == SpeedUnit.bites,
      );
      //
      final String mobileText = TextService().formatSpeed(
        todayMobileUsage.round(),
        false,
      );
      final String wifiText = TextService().formatSpeed(
        todayWifiUsage.round(),
        false,
      );
      //  isShowUpAndDownSpeed = true;
      // Update the service's notification with current speed values
      await FlutterForegroundTask.updateService(
        notificationTitle:
            shouldShowDownloadSpeedOnly
                ? " Down: $curRxSpeedText/s"
                : 'Down: $curRxSpeedText/s Up: $curTxSpeedText/s',
        notificationText: 'Mobile: $mobileText  Wifi: $wifiText ',
        smalliconText: "$curSpeedText/s",
      );
      try {
        DataUsageStorageService.instance.writeToIsolateBox(
          DateTime.now(),
          isWiFi,
          shouldShowDownloadSpeedOnly
              ? (downloadSpeedInKbps).round()
              : totalSpeed.round(),
        );
      } catch (e) {
        debugPrint(e.toString());
      }

      List<DataUsageModel> values =
          DataUsageStorageService.instance.isolateBox.values.toList();
      List<Map<String, dynamic>> serializedValues =
          values.map((e) {
            return {
              "date": e.date.toIso8601String(),
              "mobile": e.mobile,
              "wifi": e.wifi,
            };
          }).toList();

      // Send speed data back to the main isolate
      FlutterForegroundTask.sendDataToMain({"values": serializedValues});
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool b) async {
    // Cleanup if needed
  }
}
