



import 'package:flutter/material.dart';
import 'package:flutter_internet_meter/foreground_task_service.dart';
import 'package:flutter_internet_meter/storage_service.dart';
import 'package:flutter_internet_meter/usage_data_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DataUsageStorageService.instance.init();
 
  await SpeedMonitorService().startForegroundService();



  runApp(MaterialApp(home: UsageDataScreen()));
}
