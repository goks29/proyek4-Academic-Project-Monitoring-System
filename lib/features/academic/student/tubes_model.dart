import 'package:hive/hive.dart';

part 'tubes_model.g.dart';

@HiveType(typeId: 0)
class TubesModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late List<String> scope;

  @HiveField(4)
  late DateTime deadline;

  @HiveField(5)
  late DateTime createdAt;

  TubesModel({
    required this.id,
    required this.title,
    required this.description,
    required this.scope,
    required this.deadline,
    required this.createdAt,
  });
}