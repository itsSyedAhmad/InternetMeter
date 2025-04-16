import 'dart:async';
import 'dart:io';


import 'dart:math';
import 'package:flutter_internet_meter/notification_service.dart';


class NetworkSpeedService {
  static StreamSubscription? _subscription;

  static void startMonitoring() {
    _subscription?.cancel(); // avoid duplicate subscriptions
    _subscription = NetworkSpeedMonitor.speedStream().listen((kbps) {
      final random = Random();
      int randomNumber = random.nextInt(100); // For demo
      NotificationService.showSpeedNotification(randomNumber.toDouble());
    });
  }

  static void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }
}

class NetworkSpeedMonitor {
  static Future<int> getReceivedBytes() async {
    final stats = await NetworkInterface.list();
    int total = 0;
    for (var interface in stats) {
      for (var addr in interface.addresses) {
        total += addr.rawAddress.length;
      }
    }
    return total;
  }

  static Stream<double> speedStream({Duration interval = const Duration(seconds: 1)}) async* {
    int previous = await getReceivedBytes();

    while (true) {
      await Future.delayed(interval);
      int current = await getReceivedBytes();
      double kbps = (current - previous) / 1024;
      previous = current;
      yield kbps;
    }
  }
}
