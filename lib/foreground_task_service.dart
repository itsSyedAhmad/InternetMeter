import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_internet_meter/storage_service.dart';

Future<void> startForegroundService() async {
 

  // Initialize the foreground task service
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'speed_monitor_channel',
      channelName: 'Speed Monitor Service',
      channelDescription: 'Shows internet speed even when app is closed',
      channelImportance: NotificationChannelImportance.HIGH,
      priority: NotificationPriority.HIGH,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
      ),
    ),
    iosNotificationOptions: const IOSNotificationOptions(),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 1000, // 1 second
      autoRunOnBoot: true,
      allowWakeLock: true,
    ),
  );

  // Start the service
  await FlutterForegroundTask.startService(
    notificationTitle: 'Speed Monitor Running',
    notificationText: 'Monitoring speed in background...',
    callback: startCallback,
  );
  // late Timer timer;
  // timer=Timer.periodic(Duration(seconds: 2), (_){
  //     print("timer");
  //       DataUsageStorageService.instance.writeFunction(DateTime.now(), false, 40);

  //   });
  
}

@pragma('vm:entry-point')
void startCallback() {
  print("startCallback>>> Initialized");
  // Initialize communication with the isolate using a SendPort
  final receivePort = ReceivePort();
  final sendPort = receivePort.sendPort;
    
  // Start the task handler with the SendPort for communication
  FlutterForegroundTask.setTaskHandler(NetworkSpeedTaskHandler(sendPort: sendPort));

  // Listen for messages from the isolate (if necessary)
  receivePort.listen((message) {
    // Handle communication from isolate, if needed
    print("Received from isolate: $message");
     // Use the main thread to write to the storage service
  
    //D/ Use the main thread to write to the storage service
 // SchedulerBinding.instance.addPostFrameCallback((_) {
    DataUsageStorageService.instance.writeFunction(DateTime.now(), false, message.round());
  //});
  
  });
}

class NetworkSpeedTaskHandler extends TaskHandler {
  final SendPort sendPort;
  int _previousBytes = 0;

  // Constructor with SendPort for communication
  NetworkSpeedTaskHandler({required this.sendPort});

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // Initialize the DataUsageStorageService here or any other resource needed
    await _initializeResources();
    _previousBytes = await _getReceivedBytes();
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    _checkSpeedAndNotify();
  //   late Timer timer;
  // timer=Timer.periodic(Duration(seconds: 2), (_){
  //     print("timer");
  //       DataUsageStorageService.instance.writeFunction(DateTime.now(), false, 40);

  //   });
  }

  Future<void> _checkSpeedAndNotify() async {
    print("Checking speed...");
    final currentBytes = await _getReceivedBytes();
    var kbps = (currentBytes - _previousBytes) / 1024;
    _previousBytes = currentBytes;
    var r = Random();
    kbps = r.nextInt(100).roundToDouble();

    await FlutterForegroundTask.updateService(
      notificationTitle: 'Speed Monitor Running',
      notificationText: '${kbps} KB/s',
    );
    
    // Update the data storage with speed data
    

    // Optionally send updates back to the main isolate
    sendPort.send(kbps);
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // Clean up resources if needed
  }

  Future<void> _initializeResources() async {
    // Initialize storage or any other required resources here
    await DataUsageStorageService.instance.init();  // Assuming this initializes the data storage
  }

  Future<int> _getReceivedBytes() async {
    // Replace with actual network byte calculation logic
    return 100; // Example value, replace with real data fetching logic
  }
}
