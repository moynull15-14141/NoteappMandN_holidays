import 'package:hive/hive.dart';
import 'package:noteapp/data/models/settings_model.dart';

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 1;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final fieldId = reader.readByte();
      fields[fieldId] = reader.read();
    }
    return SettingsModel(
      pinCode: fields[0] as String?,
      isDarkTheme: fields[1] as bool? ?? false,
      autoLockDurationMinutes: fields[2] as int? ?? 15,
      lastAuthTime: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer.writeByte(4); // Number of fields
    writer.writeByte(0);
    writer.write(obj.pinCode);
    writer.writeByte(1);
    writer.write(obj.isDarkTheme);
    writer.writeByte(2);
    writer.write(obj.autoLockDurationMinutes);
    writer.writeByte(3);
    writer.write(obj.lastAuthTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
