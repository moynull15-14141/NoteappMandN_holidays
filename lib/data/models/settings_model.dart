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

  @HiveField(4)
  late String? securityQuestion;

  @HiveField(5)
  late String? securityAnswer;

  @HiveField(6)
  late String? userName; // LAN Chat unique user name

  SettingsModel({
    this.pinCode,
    this.isDarkTheme = false,
    this.autoLockDurationMinutes = 15,
    this.lastAuthTime,
    this.securityQuestion,
    this.securityAnswer,
    this.userName,
  });

  SettingsModel.empty();

  SettingsModel copyWith({
    String? pinCode,
    bool? isDarkTheme,
    int? autoLockDurationMinutes,
    DateTime? lastAuthTime,
    String? securityQuestion,
    String? securityAnswer,
    String? userName,
  }) {
    return SettingsModel(
      pinCode: pinCode ?? this.pinCode,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      autoLockDurationMinutes:
          autoLockDurationMinutes ?? this.autoLockDurationMinutes,
      lastAuthTime: lastAuthTime ?? this.lastAuthTime,
      securityQuestion: securityQuestion ?? this.securityQuestion,
      securityAnswer: securityAnswer ?? this.securityAnswer,
      userName: userName ?? this.userName,
    );
  }
}
