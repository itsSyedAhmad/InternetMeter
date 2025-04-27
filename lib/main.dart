import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

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
  await DataUsageStorageService.instance.initMainBox();

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (context) => AppSettingCubit())],
      child: BlocBuilder<AppSettingCubit, AppSetttingState>(
        builder: (context, themeState) {
          return MaterialApp(
            home: UsageDataScreen(),
            theme: appLightTheme(),
            darkTheme: appDarkTheme(),
            themeMode: themeState.themeMode,
          );
        },
      ),
    ),
  );
}
// //

//void main() => runApp(MaterialApp(home: MyPathCarDemo()));
