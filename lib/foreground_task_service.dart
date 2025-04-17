import 'dart:async';
import 'dart:isolate';
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

    await FlutterForegroundTask.startService(
      notificationTitle: 'Speed Monitor Running',
      notificationText: 'Monitoring speed in background...',
      callback: startCallback,
    );
    final receivePort = FlutterForegroundTask.receivePort;
    if (receivePort != null) {
      receivePort.listen((data) {
        DataUsageStorageService.instance.writeFunction(
          DateTime.now(),
          false,
          data.round(),
        );
      });
    }
  }

  void _initializeForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'speed_monitor_channel',
        channelName: 'Speed Monitor Service',
        channelDescription: 'Shows internet speed even when app is closed',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        // iconData: const NotificationIconData(
        //   resType: ResourceType.mipmap,
        //   resPrefix: ResourcePrefix.ic,
        //   name: 'ic_launcher',
        // ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 1000, // 1 second
        autoRunOnBoot: true,
        allowWakeLock: true,
      ),
    );
  }

  
}
@pragma('vm:entry-point')
  void startCallback() {
    FlutterForegroundTask.setTaskHandler(NetworkSpeedTaskHandler());
  }
class NetworkSpeedTaskHandler extends TaskHandler {
  int _previousBytes = 0;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // await _initializeResources();
    // _previousBytes = await _getReceivedBytes();
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    _checkSpeedAndNotify(sendPort);
  }

  Future<void> _checkSpeedAndNotify(SendPort? s) async {

    final currentBytes = await _getReceivedBytes();
    double kbps = (currentBytes - _previousBytes) / 1024;
    _previousBytes = currentBytes;

    // Simulate random speed for now (replace with actual logic later)
    double lowerBound = 1000.0;
  double upperBound = 1050;
  final random = Random();
  kbps= lowerBound + random.nextDouble() * (upperBound - lowerBound);
  bool isWifi=false;
  String mobileText=isWifi?"${0}/s":"${TextService().formatSpeed(kbps.round())}/s";
  String wifitext=!isWifi?"${0}/s":"${TextService().formatSpeed(kbps.round())}/s";
    

    await FlutterForegroundTask.updateService(
      notificationTitle: 'Speed Monitor Running',
      notificationText: 'Mobile:$mobileText  Wifi: $wifitext ',
    );

    s!.send(kbps);
  }

  // Future<void> _initializeResources() async {
  //   await DataUsageStorageService.instance.init();
  // }

  Future<int> _getReceivedBytes() async {
    // Replace with real data fetch logic
    return 100;
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // Clean up resources if needed
  }
}