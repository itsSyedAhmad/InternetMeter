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

  late Box<DataUsageModel> _dataUsageBox;

  // Initialization method for the singleton instance
  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DataUsageModelAdapter());
    }

    _dataUsageBox = await Hive.openBox<DataUsageModel>('dataUsageBox');
    print("completely init................................");
  }

  ValueListenable<Box<DataUsageModel>> get listenableBox => _dataUsageBox.listenable();

  List<DataUsageModel> getDataUsageList() {
    return _dataUsageBox.values.toList();
  }

  Future<void> writeFunction(DateTime date, bool isWifi, int kbps) async {
    print("writing................................");
    print(_dataUsageBox.isOpen);
    final index = _dataUsageBox.values.toList().indexWhere((data) => isSameDay(data.date, date));

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

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
