class FoodItem {
  final int id;
  final String name;
  final String producer;
  final int calories;
  final double protein;
  final double fat;
  final double carbohydrates;
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
}

class UserMeal {
  final int id;
  final FoodItem foodItem;
  double quantity;
  final DateTime datetime;
  final String owner;

  UserMeal({
    required this.id,
    required this.foodItem,
    required this.quantity,
    required this.datetime,
    required this.owner,
  });

  factory UserMeal.fromJson(Map<String, dynamic> json) {
    return UserMeal(
      id: json['id'],
      foodItem: FoodItem.fromJson(json['food_item_detail']),
      quantity: json['quantity'],
      datetime: DateTime.parse(json['datetime']),
      owner: json['owner'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food_item': foodItem.id,
      'quantity': quantity,
      'datetime': datetime.toIso8601String(),
      'owner': owner,
    };
  }
}
