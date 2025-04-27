class TextService {
  String formatSpeed(int speed, bool isBitsPerSecond, {bool test = false}) {
    double value = speed.toDouble();
    String unit =
        isBitsPerSecond ? 'kb' : 'KB'; // Default to bits (b) or bytes (KB)

    // Convert KB to bits if isBitsPerSecond is true
    // Convert KB to bits if isBitsPerSecond is true
    if (isBitsPerSecond) {
      value *= 8; // Convert bytes to bits (1 byte = 8 bits)

      if (value >= 1024) {
        value /= 1024;
        unit = 'kb'; // Kilobits
      }
      if (value >= 1024) {
        value /= 1024;
        unit = 'mb'; // Megabits
      }
      if (value >= 1024) {
        value /= 1024;
        unit = 'gb'; // Gigabits
      }

      return '${value.toStringAsFixed(value < 1024 ? 0 : 1)} $unit'; // Show decimal for kb, mb, gb
    }
    // Convert KB to bytes (KB, MB, GB)
    else {
      //print(" isBitsPerSecond2>>>>>>> $isBitsPerSecond");
      if (value >= 1024) {
        value /= 1024;
        unit = 'MB'; // Megabytes
        if (value >= 1024) {
          value /= 1024;
          unit = 'GB'; // Gigabytes
        }
        return '${value.toStringAsFixed(1)} $unit'; // Show decimal for MB/s and GB/s
      } else {
        return '${value.round()} $unit'; // Don't show decimal for KB/s
      }
    }
  }
}
