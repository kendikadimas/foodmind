class NutritionInfo {
  final double calories;
  final double protein; // gram
  final double carbs; // gram
  final double fat; // gram
  final double fiber; // gram
  final double sugar; // gram
  final double sodium; // mg
  final String healthScore; // A, B, C, D

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.healthScore,
  });

  factory NutritionInfo.fromFoodName(String foodName) {
    // Simple estimation based on food type
    // In real app, you would use a nutrition API or database
    final food = foodName.toLowerCase();
    
    if (food.contains('nasi') || food.contains('rice')) {
      return NutritionInfo(
        calories: 150,
        protein: 3,
        carbs: 30,
        fat: 0.3,
        fiber: 0.4,
        sugar: 0.1,
        sodium: 1,
        healthScore: 'B',
      );
    } else if (food.contains('ayam') || food.contains('chicken')) {
      return NutritionInfo(
        calories: 200,
        protein: 25,
        carbs: 0,
        fat: 8,
        fiber: 0,
        sugar: 0,
        sodium: 70,
        healthScore: 'A',
      );
    } else if (food.contains('sayur') || food.contains('vegetable')) {
      return NutritionInfo(
        calories: 25,
        protein: 2,
        carbs: 5,
        fat: 0.2,
        fiber: 2.5,
        sugar: 3,
        sodium: 10,
        healthScore: 'A',
      );
    } else if (food.contains('mie') || food.contains('noodle')) {
      return NutritionInfo(
        calories: 180,
        protein: 5,
        carbs: 35,
        fat: 2,
        fiber: 1,
        sugar: 1,
        sodium: 400,
        healthScore: 'C',
      );
    } else if (food.contains('gorengan') || food.contains('fried')) {
      return NutritionInfo(
        calories: 300,
        protein: 8,
        carbs: 25,
        fat: 20,
        fiber: 1,
        sugar: 2,
        sodium: 200,
        healthScore: 'D',
      );
    }
    
    // Default values for unknown foods
    return NutritionInfo(
      calories: 150,
      protein: 8,
      carbs: 20,
      fat: 5,
      fiber: 2,
      sugar: 3,
      sodium: 100,
      healthScore: 'B',
    );
  }

  String getHealthAdvice() {
    switch (healthScore) {
      case 'A':
        return 'Sangat sehat! Makanan ini kaya nutrisi dan rendah kalori.';
      case 'B':
        return 'Cukup sehat. Pilihan yang baik untuk dikonsumsi secara teratur.';
      case 'C':
        return 'Perlu perhatian. Batasi konsumsi dan imbangi dengan makanan sehat.';
      case 'D':
        return 'Kurang sehat. Sebaiknya dikonsumsi sesekali saja.';
      default:
        return 'Informasi nutrisi terbatas.';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'healthScore': healthScore,
    };
  }
}