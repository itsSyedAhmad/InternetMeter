import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_internet_meter/constants/constants.dart';
import 'package:flutter_internet_meter/theme/theme.dart';

import '../widgets/widgets.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CustomTheme theme = Theme.of(context).extension<CustomTheme>()!;
    return Scaffold(
      backgroundColor: theme.primaryContainerColor,
      appBar: AppBar(
        backgroundColor: theme.secondaryColor,
        title: Text(
          prefernces,
          style: theme.heading1!.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<AppSettingCubit, AppSetttingState>(
          builder: (context, settingState) {
            return Column(
              children: [
                const SizedBox(height: 10),
                ListTile(
                  onTap: () {},
                  title: Text(notificationPreferenceTitle, style: theme.title1),
                  subtitle: Text(
                    notificationPreferenceSubtitle,
                    style: theme.subtitle1,
                  ),
                  trailing: Checkbox(
                    value:
                        settingState.notificationPreference ==
                        NotificationPreference.onlyWhenInternetIsConnected,
                    onChanged: (bool? value) {
                      bool onlyWhenInternetIsConnected = value ?? false;
                      context.read<AppSettingCubit>().setNotificationPreference(
                        onlyWhenInternetIsConnected
                            ? NotificationPreference.onlyWhenInternetIsConnected
                            : NotificationPreference.always,
                      );
                    },
                  ),
                ),
                Divider(),
                ListTile(
                  onTap: () async {},
                  title: Text(showUpDownTitle, style: theme.title1),
                  subtitle: Text(showUpDownSubtitle, style: theme.subtitle1),
                  trailing: Checkbox(
                    value:
                        settingState.speedIndicatorType ==
                                SpeedIndicatorType.onlyDownloadSpeed
                            ? false
                            : true,
                    onChanged: (bool? value) {
                      bool downloadAndUploadBoth = value ?? false;
                      context.read<AppSettingCubit>().setSpeedIndicatorType(
                        downloadAndUploadBoth
                            ? SpeedIndicatorType.dowloadAndUploadBoth
                            : SpeedIndicatorType.onlyDownloadSpeed,
                      );
                    },
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(speedUnitsTitle, style: theme.title1),
                  subtitle: Text(speedUnitsinBytes, style: theme.subtitle1),
                  trailing: DropdownButton<SpeedUnit>(
                    value:
                        settingState
                            .speedUnit, // you need to pass the current selected value here
                    onChanged: (SpeedUnit? newValue) {
                      if (newValue != null) {
                        context.read<AppSettingCubit>().setSpeedUnit(newValue);
                      }
                    },
                    items:
                        SpeedUnit.values.map((SpeedUnit unit) {
                          return DropdownMenuItem<SpeedUnit>(
                            value: unit,
                            child: Text(
                              unit == SpeedUnit.bytes ? "Bytes" : "Bits",
                              style: theme.subtitle1,
                            ),
                          );
                        }).toList(),
                  ),
                ),
                Divider(),
                ListTile(
                  onTap: () {},
                  title: Text(dataUsageTitle, style: theme.title1),
                  subtitle: Text(dataUsageSubtitle, style: theme.subtitle1),
                ),
                Divider(),
                ListTile(
                  onTap: () {
                    showThemeDialog(context, theme);
                  },
                  title: Text(themeTitle, style: theme.title1),
                  subtitle: Text(themeSubtitle, style: theme.subtitle1),
                ),
                Divider(),
                ListTile(
                  onTap: () {
                    _showResetConfirmation(context);
                  },
                  //TODO: use Theme
                  title: Text("Reset Stats", style: theme.title1),
                  subtitle: Text("Clear Data", style: theme.subtitle1),
                ),
                Divider(),
                ListTile(
                  onTap: () {
                    viewAboutDialog(
                      context,
                      aboutTitle,
                      aboutDescription,
                      theme,
                    );
                  },
                  title: Text(aboutTitle, style: theme.title1),
                  subtitle: Text(aboutSubtitle, style: theme.subtitle1),
                ),
                Divider(),
              ],
            );
          },
        ),
      ),
    );
  }

  //TODO: use Theme
  void _showResetConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to reset the stats?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      FlutterForegroundTask.sendDataToTask({
                        "resetStats": true,
                      });
                      Navigator.pop(context); // Close the sheet
                      // Add your reset logic here
                      print("Stats reset");
                    },
                    child: Text('Yes'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Just close the sheet
                    },
                    child: Text('No'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
