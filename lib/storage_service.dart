import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data_usage.dart';

class StorageService {
  // Private static instance for Singleton pattern
  static final StorageService _instance = StorageService._internal();

  // Private constructor
  StorageService._internal();

  // Static method to access the instance
  static StorageService get instance => _instance;

  late Box<DataUsageModel> _dataUsageBox;
  late Box<int> _themeBox;

  // Initialization method for the singleton instance
  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DataUsageModelAdapter());
    }

    _dataUsageBox = await Hive.openBox<DataUsageModel>('dataUsageBox');
    _themeBox = await Hive.openBox<int>('themeMode');
  }

  ValueListenable<Box<DataUsageModel>> get listenableBox =>
      _dataUsageBox.listenable();

  List<DataUsageModel> getDataUsageList() {
    return _dataUsageBox.values.toList();
  }

  Future<void> writeFunction(DateTime date, bool isWifi, int kbps) async {
    final index = _dataUsageBox.values.toList().indexWhere(
      (data) => isSameDay(data.date, date),
    );

    if (index != -1) {
      final key = _dataUsageBox.keyAt(index);
      final existingData = _dataUsageBox.get(key)!;

      if (isWifi) {
        existingData.wifi += kbps;
      } else {
        existingData.mobile += kbps;
      }

      await _dataUsageBox.put(key, existingData);
    } else {
      final newData = DataUsageModel(
        date: date,
        mobile: isWifi ? 0 : kbps,
        wifi: isWifi ? kbps : 0,
      );
      await _dataUsageBox.add(newData);
    }
  }

  DataUsageModel getTodayUsage() {
    final today = DateTime.now();

    return _dataUsageBox.values.firstWhere(
      (data) => isSameDay(data.date, today),
      orElse: () => DataUsageModel(date: today, mobile: 0, wifi: 0),
    );
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  putTheme(ThemeMode themeMode) async {
    await _themeBox.put('theme', themeMode.index);
  }

  getTheme() {
    _themeBox.get('theme');
  }
}
