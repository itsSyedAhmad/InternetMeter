import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_internet_meter/foreground_task_service.dart';
import 'package:flutter_internet_meter/storage_service.dart';
import 'package:flutter_internet_meter/usage_data_screen.dart';

import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //permission
  // Android 13+, you need to allow notification permission to display foreground service notification.
  //
  // iOS: If you need notification, ask for permission.
  final NotificationPermission notificationPermission =
      await FlutterForegroundTask.checkNotificationPermission();

  if (notificationPermission != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();
  }

  // //init services
  await StorageService.instance.init();
  await SpeedMonitorService().startForegroundService();

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (context) => ThemeCubit())],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            home: UsageDataScreen(),
            theme: appLightTheme(),
            darkTheme: appDarkTheme(),
            themeMode: themeState.themeMode,
          );
        }
      ),
    ),
  );
}
// //

//void main() => runApp(MaterialApp(home: MyPathCarDemo()));
