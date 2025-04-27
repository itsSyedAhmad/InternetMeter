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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,

              child: Image.asset("assets/icon/fast.png"),
            ),
            SizedBox(height: 20),
            Text(
              "Email : saifrock7185@gmail.com",
              style: theme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              "Copyright © 2025 AppTide Creations",
              style: theme.subtitle1!.copyWith(fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            Text(
              "All Rights Reserved",
              style: theme.subtitle1!.copyWith(fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(subtitle, style: theme.subtitle1),
          ],
        ),
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
