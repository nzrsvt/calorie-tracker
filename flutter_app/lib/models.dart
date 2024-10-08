class UserProfile {
  final int id;
  final String username;
  final String email;
  final String gender;
  final int age;
  final int height;
  final double weight;
  final String activityLevel;
  final String goal;
  final double calorieIntake;
  final double proteinIntake;
  final double fatIntake;
  final double carbohydrateIntake;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal,
    required this.calorieIntake,
    required this.proteinIntake,
    required this.fatIntake,
    required this.carbohydrateIntake,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      gender: json['gender'],
      age: json['age'],
      height: json['height'],
      weight: json['weight'].toDouble(),
      activityLevel: json['activity_level'],
      goal: json['goal'],
      calorieIntake: json['calorie_intake'].toDouble(),
      proteinIntake: json['protein_intake'].toDouble(),
      fatIntake: json['fat_intake'].toDouble(),
      carbohydrateIntake: json['carbohydrate_intake'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'activity_level': activityLevel,
      'goal': goal,
      'calorie_intake': calorieIntake,
      'protein_intake': proteinIntake,
      'fat_intake': fatIntake,
      'carbohydrate_intake': carbohydrateIntake,
    };
  }
}

class FoodItem {
  final int id;
  final String name;
  final String producer;
  double calories;
  double protein;
  double fat;
  double carbohydrates;
  final double portionSize;
  final String quantityUnit;
  final String owner;

  FoodItem({
    required this.id,
    required this.name,
    required this.producer,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    required this.portionSize,
    required this.quantityUnit,
    required this.owner,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      producer: json['producer'],
      calories: json['calories'],
      protein: json['protein'],
      fat: json['fat'],
      carbohydrates: json['carbohydrates'],
      portionSize: json['portion_size'],
      quantityUnit: json['quantity_unit'],
      owner: json['owner'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'producer': producer,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbohydrates': carbohydrates,
      'portion_size': portionSize,
      'quantity_unit': quantityUnit,
    };
  }
}

class UserMeal {
  final int id;
  final FoodItem foodItem;
  double quantity;
  final DateTime datetime;
  final String owner;
  final String mealType;
  final double portionCalories;
  final double portionFat;
  final double portionCarbohydrates;
  final double portionProteins;

  UserMeal({
    required this.id,
    required this.foodItem,
    required this.quantity,
    required this.datetime,
    required this.owner,
    required this.mealType,
    required this.portionCalories,
    required this.portionFat,
    required this.portionCarbohydrates,
    required this.portionProteins,
  });

  factory UserMeal.fromJson(Map<String, dynamic> json) {
    return UserMeal(
      id: json['id'],
      foodItem: FoodItem.fromJson(json['food_item_detail']),
      quantity: json['quantity'],
      datetime: DateTime.parse(json['datetime']),
      owner: json['owner'],
      mealType: json['meal_type'],
      portionCalories: json['portion_calories'],
      portionFat: json['portion_fat'],
      portionCarbohydrates: json['portion_carbohydrates'],
      portionProteins: json['portion_proteins'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food_item': foodItem.id,
      'quantity': quantity,
      'datetime': datetime.toIso8601String(),
      'owner': owner,
      'meal_type': mealType,
      'portion_calories': portionCalories,
      'portion_fat': portionFat,
      'portion_carbohydrates': portionCarbohydrates,
      'portion_proteins': portionProteins,
    };
  }
}
