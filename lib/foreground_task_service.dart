import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_internet_meter/data_usage.dart';
import 'package:flutter_internet_meter/storage_service.dart';
import 'package:flutter_internet_meter/text_service.dart';

class SpeedMonitorService {
  static final SpeedMonitorService _instance = SpeedMonitorService._internal();

  factory SpeedMonitorService() {
    return _instance;
  }

  SpeedMonitorService._internal();

  Future<void> startForegroundService() async {
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
   var resMap = data as Map<Object?, Object?>;
    
     
       List<DataUsageModel> usageList = (data["values"] as List)
      .map((e) => DataUsageModel.fromMap(e as Map<String, dynamic>))
      .toList();
      
       DataUsageStorageService.instance.writeToMainBox(
         usageList
        );
      
     
      

      
   });
  }
}

// Initialize the foreground task
void _initializeForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'speed_monitor_channel',
      channelName: 'Speed Monitor Service',
      channelDescription: 'Shows internet speed even when app is closed',
      channelImportance: NotificationChannelImportance.HIGH,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: const IOSNotificationOptions(),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(1000),
      autoRunOnBoot: true,
      allowWakeLock: true,
    ),
  );
}

// Entry point for the callback function in the foreground task
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(NetworkSpeedTaskHandler());
}

class NetworkSpeedTaskHandler extends TaskHandler {
  static double currentKbps = 0;
  int i = 0;
  bool hasInit=false;
   //temporary bool value
  bool isShowUpAndDownSpeed = false;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter t) async {
    await DataUsageStorageService.instance.initIsolateBox();
    hasInit=true;
    // Initialization code if needed (like getting initial byte count)
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _checkSpeedAndNotify();
  }

  Future<void> _checkSpeedAndNotify() async {
     if(hasInit){
    double kbps = 0;
    double rxKBps = 0;
    double txKBps = 0;
    bool isWiFi = false;

    var resMap = await FlutterForegroundTask.getSpeed();
    if (i != 0) {
      kbps = resMap["kbps"] as double;
      rxKBps = resMap["rxKBps"] as double;
      txKBps = resMap["txKBps"] as double;
      isWiFi = resMap["isWiFi"] as bool;
    }
    i++;

    final todayUsageBlock = DataUsageStorageService.instance.getTodayUsageFromIsolateBox();
    final todayWifiUsage = todayUsageBlock.wifi;
    final todayMobileUsage = todayUsageBlock.mobile;
    final curSpeedText = TextService().formatSpeed(kbps.round());
    final curRxSpeedText = TextService().formatSpeed(rxKBps.round());
    final curTxSpeedText = TextService().formatSpeed(txKBps.round());
    final String mobileText = TextService().formatSpeed(
      todayMobileUsage.round(),
    );
    final String wifiText = TextService().formatSpeed(todayWifiUsage.round());
//  isShowUpAndDownSpeed = true;
    // Update the service's notification with current speed values
    await FlutterForegroundTask.updateService(
      notificationTitle:
          isShowUpAndDownSpeed
              ? 'Down: $curRxSpeedText/s Up: $curTxSpeedText/s'
              : 'Speed Monitor Running',
       notificationText: 'current speed: 300kb/s \n\nMobile: $mobileText  Wifi: $wifiText ',
      smalliconText: "$curSpeedText/s",
    );
    try{
     
        DataUsageStorageService.instance.writeToIsolateBox(
      DateTime.now(),
      isWiFi,
      (kbps).round(),
    );

      
      

    }
    catch(e){
      debugPrint(e.toString());

    }
     
List<DataUsageModel> values=DataUsageStorageService.instance.isolateBox.values.toList();
List<Map<String, dynamic>> serializedValues = values.map((e) {
  return {
  
  "date": e.date.toIso8601String(),
  "mobile": e.mobile,
  "wifi": e.wifi,
};
}).toList();
    
    // Send speed data back to the main isolate
    FlutterForegroundTask.sendDataToMain({"kbps": kbps, "isWiFi": isWiFi,"values": serializedValues,});
     }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool b) async {
    // Cleanup if needed
  }
}
