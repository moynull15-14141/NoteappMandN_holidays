import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class DiaryEntryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String body;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  late DateTime updatedAt;

  @HiveField(5)
  late String mood; // emoji

  @HiveField(6)
  late List<String> imagePaths;

  @HiveField(7)
  late bool isFavorite;

  @HiveField(8)
  late List<String> tags;

  DiaryEntryModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.mood,
    required this.imagePaths,
    required this.isFavorite,
    required this.tags,
  });

  DiaryEntryModel.empty();

  DiaryEntryModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? mood,
    List<String>? imagePaths,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return DiaryEntryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mood: mood ?? this.mood,
      imagePaths: imagePaths ?? this.imagePaths,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'mood': mood,
      'imagePaths': imagePaths,
      'isFavorite': isFavorite,
      'tags': tags,
    };
  }

  factory DiaryEntryModel.fromJson(Map<String, dynamic> json) {
    return DiaryEntryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      mood: json['mood'] as String? ?? '😊',
      imagePaths: List<String>.from(json['imagePaths'] as List? ?? []),
      isFavorite: json['isFavorite'] as bool? ?? false,
      tags: List<String>.from(json['tags'] as List? ?? []),
    );
  }
}
