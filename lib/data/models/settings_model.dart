import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class SettingsModel extends HiveObject {
  @HiveField(0)
  late String? pinCode;

  @HiveField(1)
  late bool isDarkTheme;

  @HiveField(2)
  late int autoLockDurationMinutes;

  @HiveField(3)
  late DateTime? lastAuthTime;

  SettingsModel({
    this.pinCode,
    this.isDarkTheme = false,
    this.autoLockDurationMinutes = 15,
    this.lastAuthTime,
  });

  SettingsModel.empty();

  SettingsModel copyWith({
    String? pinCode,
    bool? isDarkTheme,
    int? autoLockDurationMinutes,
    DateTime? lastAuthTime,
  }) {
    return SettingsModel(
      pinCode: pinCode ?? this.pinCode,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      autoLockDurationMinutes:
          autoLockDurationMinutes ?? this.autoLockDurationMinutes,
      lastAuthTime: lastAuthTime ?? this.lastAuthTime,
    );
  }
}
