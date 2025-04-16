

import 'package:flutter/material.dart';
import 'package:flutter_internet_meter/network_speed_monitor.dart';
import 'package:flutter_internet_meter/notification_service.dart' show NotificationService;
import 'package:flutter_internet_meter/storage_service.dart';
import 'package:flutter_internet_meter/usage_data_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataUsageStorageService.init();
  await NotificationService.init();
  
  NetworkSpeedService.startMonitoring();

  runApp(MaterialApp(home: UsageDataScreen()));
}
