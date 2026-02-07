import 'package:hive/hive.dart';
import 'package:noteapp/data/models/diary_entry_model.dart';

class DiaryEntryModelAdapter extends TypeAdapter<DiaryEntryModel> {
  @override
  final int typeId = 0;

  @override
  DiaryEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final fieldId = reader.readByte();
      fields[fieldId] = reader.read();
    }
    return DiaryEntryModel(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      mood: fields[5] as String? ?? '😊',
      imagePaths: List<String>.from(fields[6] as List? ?? []),
      isFavorite: fields[7] as bool? ?? false,
      tags: List<String>.from(fields[8] as List? ?? []),
    );
  }

  @override
  void write(BinaryWriter writer, DiaryEntryModel obj) {
    writer.writeByte(9); // Number of fields
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.body);
    writer.writeByte(3);
    writer.write(obj.createdAt);
    writer.writeByte(4);
    writer.write(obj.updatedAt);
    writer.writeByte(5);
    writer.write(obj.mood);
    writer.writeByte(6);
    writer.write(obj.imagePaths);
    writer.writeByte(7);
    writer.write(obj.isFavorite);
    writer.writeByte(8);
    writer.write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
