import 'dart:async';

import 'dart:math';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
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

    FlutterForegroundTask.addTaskDataCallback((data){
     
        DataUsageStorageService.instance.writeFunction(
          DateTime.now(),
          false,
          (data as double).round(),
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
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions:  ForegroundTaskOptions(
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
  
  static  double currentKbps = 0;

  @override
  Future<void> onStart(DateTime timestamp,TaskStarter t) async {
    DataUsageStorageService.instance.init();
    // Initialization code if needed (like getting initial byte count)
  }

  @override
  void onRepeatEvent(DateTime timestamp,) {
    _checkSpeedAndNotify();
  }

  Future<void> _checkSpeedAndNotify() async {
    
    double kbps = 0;
  

    // Simulate random speed for now (replace with actual logic later)
    double lowerBound = 1000.0;
    double upperBound = 1050;
    final random = Random();
    kbps = lowerBound + random.nextDouble() * (upperBound - lowerBound);

   // bool isWifi = false;
    final todayUsageBlock=DataUsageStorageService.instance.getTodayUsage();
    final todayWifiUsage=todayUsageBlock.wifi;
    final todayMobileUsage=todayUsageBlock.mobile;
    final curSpeedText= TextService().formatSpeed(kbps.round());
    final String mobileText = TextService().formatSpeed(todayMobileUsage.round());
    final String wifiText = TextService().formatSpeed(todayWifiUsage.round());


    // Update the service's notification with current speed values
    await FlutterForegroundTask.updateService(
      notificationTitle: 'Speed Monitor Running',
      notificationText: 'Mobile: $mobileText  Wifi: $wifiText ',
      smalliconText: curSpeedText
    
      );
      
      DataUsageStorageService.instance.writeFunction(
          DateTime.now(),
          false,
          (kbps).round(),
        );
      
     
    
 // Send speed data back to the main isolate
   FlutterForegroundTask.sendDataToMain(kbps);
   
    
  }



  @override
  Future<void> onDestroy(DateTime timestamp, bool b) async {
    // Cleanup if needed
  }
}
