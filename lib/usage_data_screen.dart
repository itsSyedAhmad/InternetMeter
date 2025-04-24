


import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_internet_meter/data_usage.dart';
import 'package:flutter_internet_meter/storage_service.dart';
import 'package:flutter_internet_meter/text_service.dart';
import 'package:hive/hive.dart';

class UsageDataScreen extends StatefulWidget {
  const UsageDataScreen({super.key});

  static String _month(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  State<UsageDataScreen> createState() => _UsageDataScreenState();
}

class _UsageDataScreenState extends State<UsageDataScreen> {
  @override
  void initState() {
     FlutterForegroundTask.initCommunicationPort(); // Re
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[200]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildFancyAppBar(),
            _buildHeader(),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: DataUsageStorageService.instance.listenableBox,
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
                        //  print("same da $date $wifi $mobile");;

                        break;
                      }
                    }

                    return {
                      'date': index == 0
                          ? 'Today'
                          : '${date.day.toString().padLeft(2, '0')}-${UsageDataScreen._month(date.month)}-${date.year}',
                      'mobile': TextService().formatSpeed(mobile)    ,
                      'wifi': TextService().formatSpeed(wifi)    ,
                      'total': TextService().formatSpeed(total)    ,
                    };
                  });

                  return ListView.builder(
                    itemCount: usage.length,
                    itemBuilder: (context, index) {
                      final row = usage[index];
                      return _animatedRow(row);
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _cell('Date', bold: true),
          _cell('Mobile', bold: true),
          _cell('WiFi', bold: true),
          _cell('Total', bold: true),
        ],
      ),
    );
  }

  Widget _animatedRow(Map<String, String> row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
      child: Card(
        elevation: 5,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _animatedCell(row['date']!),
            _animatedCell(row['mobile']!),
            _animatedCell(row['wifi']!),
            _animatedCell(row['total']!),
          ],
        ),
      ),
    );
  }

  Widget _buildFancyAppBar() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo, Colors.deepPurpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 16),
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
    );
  }
}


Widget _animatedCell(String text) {
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
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _cell(String text, {bool bold = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.blue[100],
        child: Text(
          text,
          style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }


bool isSameDay(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}
