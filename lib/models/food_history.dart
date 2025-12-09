import 'package:hive/hive.dart';

part 'food_history.g.dart';

@HiveType(typeId: 0)
class FoodHistory extends HiveObject {
  @HiveField(0)
  late String mainFood;

  @HiveField(1)
  late List<String> alternatives;

  @HiveField(2)
  late List<String> reasoning;

  @HiveField(3)
  late String taste;

  @HiveField(4)
  late String style;

  @HiveField(5)
  late String weather;

  @HiveField(6)
  late DateTime timestamp;

  FoodHistory({
    required this.mainFood,
    required this.alternatives,
    required this.reasoning,
    required this.taste,
    required this.style,
    required this.weather,
    required this.timestamp,
  });
}
