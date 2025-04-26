import 'package:flutter/material.dart';
import 'package:flutter_internet_meter/constants/app_constants.dart';
import 'package:flutter_internet_meter/theme/theme.dart';

void viewAboutDialog(
  BuildContext context,
  String title,
  String subtitle,
  CustomTheme theme,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title, style: theme.title1),
        content: Text(subtitle, style: theme.subtitle1),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(okText, style: theme.subtitle1),
          ),
        ],
      );
    },
  );
}
