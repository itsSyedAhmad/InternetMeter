import 'package:flutter/material.dart';
import 'package:flutter_internet_meter/data_usage.dart';
import 'package:flutter_internet_meter/storage_service.dart';
import 'package:flutter_internet_meter/text_service.dart';
import 'package:flutter_internet_meter/theme/theme.dart';
import 'package:hive/hive.dart';

import 'prefernces/preferences.dart';

class UsageDataScreen extends StatelessWidget {
  const UsageDataScreen({super.key});

  static String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    CustomTheme theme = Theme.of(context).extension<CustomTheme>()!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor!.withValues(alpha: 0.75),
              theme.primaryColor!.withValues(alpha: 0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildFancyAppBar(theme, context),
            _buildHeader(theme),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: DataUsageStorageService.instance.listenableBox,
                builder: (context, Box<DataUsageModel> box, _) {
                  final List<Map<String, String>> usage = List.generate(30, (
                    index,
                  ) {
                    final date = DateTime.now().subtract(Duration(days: index));
                    int mobile = 0;
                    int wifi = 0;
                    int total = 0;

                    for (var b in box.values) {
                      if (isSameDay(date, b.date)) {
                        mobile = b.mobile;
                        wifi = b.wifi;
                        total = mobile + wifi;
                        break;
                      }
                    }

                    return {
                      'date':
                          index == 0
                              ? 'Today'
                              : '${date.day.toString().padLeft(2, '0')}-${_month(date.month)}-${date.year}',
                      'mobile': TextService().formatSpeed(mobile),
                      'wifi': TextService().formatSpeed(wifi),
                      'total': TextService().formatSpeed(total),
                    };
                  });

                  return ListView.builder(
                    itemCount: usage.length,
                    itemBuilder: (context, index) {
                      final row = usage[index];
                      return _animatedRow(row, theme);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CustomTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _cell('Date', bold: true, theme: theme),
          _cell('Mobile', bold: true, theme: theme),
          _cell('WiFi', bold: true, theme: theme),
          _cell('Total', bold: true, theme: theme),
        ],
      ),
    );
  }

  Widget _animatedRow(Map<String, String> row, CustomTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
      child: Card(
        elevation: 5,
        color: theme.primaryContainerColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _animatedCell(row['date']!, theme),
            _animatedCell(row['mobile']!, theme),
            _animatedCell(row['wifi']!, theme),
            _animatedCell(row['total']!, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildFancyAppBar(CustomTheme theme, BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.secondaryColor!,
            theme.secondaryColor!.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => PreferencesScreen()),
                );
              },
              icon: Icon(Icons.settings),
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: Row(
              children: const [
                Icon(Icons.network_check, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Text(
                  "Internet Usage Summary",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _animatedCell(String text, CustomTheme theme) {
  return Expanded(
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Text(
        text,
        key: ValueKey(text),
        style: TextStyle(fontSize: 14, color: theme.primaryTextColor),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

Widget _cell(String text, {bool bold = false, required CustomTheme theme}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      color: theme.secondaryColor!.withValues(alpha: 0.5),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

bool isSameDay(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}
