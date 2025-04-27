import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data_usage.dart';

class DataUsageStorageService {
  // Private static instance for Singleton pattern
  static final DataUsageStorageService _instance = DataUsageStorageService._internal();

  // Private constructor
  DataUsageStorageService._internal();

  // Static method to access the instance
  static DataUsageStorageService get instance => _instance;

  late Box<DataUsageModel> mainBox;
 late Box<DataUsageModel> isolateBox;
 late Box _settingsBox;

Future<void> initSettingsBox() async {
  await Hive.initFlutter(); // You only need to call this once globally
  _settingsBox = await Hive.openBox('settingsBox');
}
Future<void> setUnit(String unit) async {
  await _settingsBox.put('unitChosen', unit);
}

String getUnit() {
  return _settingsBox.get('unitChosen', defaultValue: 'kbps');
}
Future<void> setShowNotification(bool value) async {
  await _settingsBox.put('showNotification', value);
}

bool getShowNotification() {
  return _settingsBox.get('showNotification', defaultValue: true);
}
  // Initialization method for the singleton instance
  Future<void> initMainBox() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DataUsageModelAdapter());
    }

    mainBox = await Hive.openBox<DataUsageModel>('dataUsageBox');
    await mainBox.add(DataUsageModel(date: DateTime.now().subtract(Duration(days: 1),),wifi: 400,mobile: 90));
  }
//
 Future<void> initIsolateBox() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DataUsageModelAdapter());
    }

    isolateBox = await Hive.openBox<DataUsageModel>('dataUsageBox_isolate');
  }

  ValueListenable<Box<DataUsageModel>> get listenableBox => mainBox.listenable();

  

  Future<void> writeToMainBox(List<DataUsageModel> newEntries) async {
  for (var newEntry in newEntries) {
    final index = mainBox.values.toList().indexWhere(
      (data) => isSameDay(data.date, newEntry.date),
    );

    if (index != -1) {
      final key = mainBox.keyAt(index);
      final existingData = mainBox.get(key)!;

      existingData.mobile = newEntry.mobile;
      existingData.wifi = newEntry.wifi;

      await mainBox.put(key, existingData);
    } else {
      await mainBox.add(newEntry);
    }
  }
}


  Future<void> writeToIsolateBox(DateTime date, bool isWifi, int kbps) async {
    final index = isolateBox.values.toList().indexWhere((data) => isSameDay(data.date, date));

    if (index != -1) {
      final key = isolateBox.keyAt(index);
      final existingData = isolateBox.get(key)!;

      if (isWifi) {
        existingData.wifi += kbps;
      } else {
        existingData.mobile += kbps;
      }

      await isolateBox.put(key, existingData);
    } else {
      final newData = DataUsageModel(
        date: date,
        mobile: isWifi ? 0 : kbps,
        wifi: isWifi ? kbps : 0,
      );
      await isolateBox.add(newData);
    }
    
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
  DataUsageModel getTodayUsageFromIsolateBox() {
  final today = DateTime.now();

  return isolateBox.values.firstWhere(
    (data) => isSameDay(data.date, today),
    orElse: () => DataUsageModel(date: today, mobile: 0, wifi: 0),
  );
}
  

} 
