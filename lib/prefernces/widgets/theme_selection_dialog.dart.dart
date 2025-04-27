import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_internet_meter/constants/constants.dart';
import 'package:flutter_internet_meter/theme/theme.dart';

Future<void> showThemeDialog(BuildContext context, CustomTheme theme) async {
  String? selectedValue = getThemeStringMode(
    context.read<AppSettingCubit>().state.themeMode,
  );

  await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
 
      return AlertDialog(
        title: Text(selectTheme, style: theme.heading1),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RadioListTile<String>(
                  title: Text(lightTheme, style: theme.title1),
                  value: lightTheme,
                  groupValue: selectedValue,
                  onChanged: (String? value) {
                    setState(() {
                      selectedValue = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text(darkTheme, style: theme.title1),
                  value: darkTheme,
                  groupValue: selectedValue,
                  onChanged: (String? value) {
                    setState(() {
                      selectedValue = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text(systemDefault, style: theme.title1),
                  value: systemDefault,
                  groupValue: selectedValue,
                  onChanged: (String? value) {
                    setState(() {
                      selectedValue = value;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            child: Text(cancelText, style: theme.subtitle1),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(okText, style: theme.subtitle1),
            onPressed: () {
              if (selectedValue != null) {
                debugPrint('Selected Theme: $selectedValue');
                // Perform actions based on the selected theme
                ThemeMode selectedTheme = getThemeModeFromString(selectedValue);
                context.read<AppSettingCubit>().setTheme(selectedTheme);
                Navigator.of(context).pop();
              } else {
                // Optionally show a message if no option is selected
              }
            },
          ),
        ],
      );
    },
  ).then((value) {
    // This block will execute after the dialog is closed
    if (value != null) {
      // Handle the selected value here if needed
      debugPrint('Theme selected in dialog: $value');
    }
  });
}

ThemeMode getThemeModeFromString(String? themeString) {
  switch (themeString) {
    case lightTheme:
      return ThemeMode.light;
    case darkTheme:
      return ThemeMode.dark;
    case systemDefault:
      return ThemeMode.system;
    default:
      return ThemeMode.system;
  }
}

String getThemeStringMode(ThemeMode? theme) {
  switch (theme) {
    case ThemeMode.light:
      return lightTheme;
    case ThemeMode.dark:
      return darkTheme;
    case ThemeMode.system:
      return systemDefault;
    default:
      return systemDefault;
  }
}
