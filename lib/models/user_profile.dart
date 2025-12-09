import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile {
  @HiveField(0)
  String? name;

  @HiveField(1)
  String? email;

  @HiveField(2)
  String? phone;

  @HiveField(3)
  List<String> allergies;

  @HiveField(4)
  List<String> medicalConditions;

  @HiveField(5)
  List<String> foodPreferences;

  @HiveField(6)
  double? dailyBudget;

  @HiveField(7)
  bool isPremium;

  UserProfile({
    this.name,
    this.email,
    this.phone,
    this.allergies = const [],
    this.medicalConditions = const [],
    this.foodPreferences = const [],
    this.dailyBudget,
    this.isPremium = false,
  });



  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    List<String>? allergies,
    List<String>? medicalConditions,
    List<String>? foodPreferences,
    double? dailyBudget,
    bool? isPremium,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      foodPreferences: foodPreferences ?? this.foodPreferences,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}