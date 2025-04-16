
import 'package:flutter/material.dart';
import 'package:flutter_internet_meter/data_usage.dart';

import 'package:flutter_internet_meter/storage_service.dart';
import 'package:hive/hive.dart';

class UsageDataScreen extends StatelessWidget {
  const UsageDataScreen({super.key});



  static String _month(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Internet Speed Meter Lite")),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: DataUsageStorageService.listenableBox,
              builder: (context, Box<DataUsageModel> box, _) {
                final List<Map<String, String>> usage = List.generate(30, (index) {
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
                    'date': index == 0 ? 'Today' : '${date.day.toString().padLeft(2, '0')}-${_month(date.month)}-${date.year}',
                    'mobile': '$mobile KB',
                    'wifi':  '$wifi KB',
                    'total': '$total KB',
                  };
                });

                return ListView.builder(
                  itemCount: usage.length,
                  itemBuilder: (context, index) {
                    final row = usage[index];
                    return Row(
                      children: [
                        _cell(row['date']!),
                        _cell(row['mobile']!),
                        _cell(row['wifi']!),
                        _cell(row['total']!),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _cell('Date', bold: true),
        _cell('Mobile', bold: true),
        _cell('WiFi', bold: true),
        _cell('Total', bold: true),
      ],
    );
  }

  Widget _cell(String text, {bool bold = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.blue[100],
        child: Text(
          text,
          style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }