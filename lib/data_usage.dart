import 'package:hive/hive.dart';



@HiveType(typeId: 0)
class DataUsageModel {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int mobile;

  @HiveField(2)
  int wifi;

  DataUsageModel({
    required this.date,
    this.mobile = 0,
    this.wifi = 0,
  });
}




class DataUsageModelAdapter extends TypeAdapter<DataUsageModel> {
  @override
  final int typeId = 0;

  @override
  DataUsageModel read(BinaryReader reader) {
    return DataUsageModel(
      date: reader.read() as DateTime,
      mobile: reader.read() as int,
      wifi: reader.read() as int,
    );
  }

  @override
  void write(BinaryWriter writer, DataUsageModel obj) {
    writer.write(obj.date);
    writer.write(obj.mobile);
    writer.write(obj.wifi);
  }
}
