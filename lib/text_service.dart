class TextService{
 String formatSpeed(int kbps) {
  double value = kbps.toDouble();
  String unit = 'KB';

  if (value >= 1024) {
    value /= 1024;
    unit = 'MB';
    if (value >= 1024) {
      value /= 1024;
      unit = 'GB';
    }
    return '${value.toStringAsFixed(2)} $unit'; // Show decimal for MB/s and GB/s
  } else {
    return '${value.round()} $unit'; // Don't show decimal for KB/s
  }
}


}