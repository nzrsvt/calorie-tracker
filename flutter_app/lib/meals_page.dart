import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';
import 'package:intl/intl.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  _MealsPageState createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  final ApiService apiService = ApiService();
  late Future<List<UserMeal>> futureTodayUserMeals;

  @override
  void initState() {
    super.initState();
    _refreshMeals();
  }

  void _refreshMeals() {
    setState(() {
      futureTodayUserMeals = apiService.fetchTodayUserMeals(context);
    });
  }

  void _editMeal(UserMeal meal) async {
    final TextEditingController quantityController = TextEditingController(text: meal.quantity.toString());
    final result = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Meal Quantity'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(double.tryParse(quantityController.text)),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        meal.quantity = result;
        await apiService.updateUserMeal(context, meal);
        _refreshMeals();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update meal: $e')),
        );
      }
    }
  }

  void _deleteMeal(UserMeal meal) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this meal?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await apiService.deleteUserMeal(context, meal.id);
        _refreshMeals();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete meal: $e')),
        );
      }
    }
  }

  Widget _buildMealTypeSection(String mealType, List<UserMeal> meals) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (var meal in meals) {
      totalCalories += meal.portionCalories;
      totalProtein += meal.portionProteins;
      totalCarbs += meal.portionCarbohydrates;
      totalFat += meal.portionFat;
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            title: Text(mealType.replaceAll('_', ' ').capitalize(),
              style: Theme.of(context).textTheme.titleLarge),
            subtitle: Text(
              'Calories: ${totalCalories.toStringAsFixed(1)} kcal\n'
              'Protein: ${totalProtein.toStringAsFixed(1)}g, '
              'Carbs: ${totalCarbs.toStringAsFixed(1)}g, '
              'Fat: ${totalFat.toStringAsFixed(1)}g',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          ...meals.map((meal) => _buildMealTile(meal)).toList(),
        ],
      ),
    );
  }

  Widget _buildMealTile(UserMeal userMeal) {
    return ListTile(
      title: Text(userMeal.foodItem.name, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        '${userMeal.quantity} ${userMeal.foodItem.quantityUnit}, ${userMeal.portionCalories.toStringAsFixed(1)} kcal\n'
        'P: ${userMeal.portionProteins.toStringAsFixed(1)}g, '
        'C: ${userMeal.portionCarbohydrates.toStringAsFixed(1)}g, '
        'F: ${userMeal.portionFat.toStringAsFixed(1)}g\n'
        '${DateFormat('HH:mm').format(userMeal.datetime)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editMeal(userMeal),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteMeal(userMeal),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary(List<UserMeal> allMeals) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (var meal in allMeals) {
      totalCalories += meal.portionCalories;
      totalProtein += meal.portionProteins;
      totalCarbs += meal.portionCarbohydrates;
      totalFat += meal.portionFat;
    }

    return Card(
      margin: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total for Today', style: Theme.of(context).textTheme.titleLarge),            const SizedBox(height: 8),
            Text('Calories: ${totalCalories.toStringAsFixed(1)} kcal'),
            Text('Protein: ${totalProtein.toStringAsFixed(1)}g'),
            Text('Carbohydrates: ${totalCarbs.toStringAsFixed(1)}g'),
            Text('Fat: ${totalFat.toStringAsFixed(1)}g'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals'),
        elevation: 0,
      ),
      body: FutureBuilder<List<UserMeal>>(
        future: futureTodayUserMeals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No meals found for today.'));
          } else {
            List<UserMeal> todayMeals = snapshot.data!;
            Map<String, List<UserMeal>> mealsByType = {
              'breakfast': [],
              'morning_snack': [],
              'lunch': [],
              'afternoon_snack': [],
              'dinner': [],
              'evening_snack': [],
            };

            for (var meal in todayMeals) {
              mealsByType[meal.mealType]!.add(meal);
            }

            return ListView(
              children: [
                _buildTotalSummary(todayMeals),
                ...mealsByType.entries
                    .where((entry) => entry.value.isNotEmpty)
                    .map((entry) => _buildMealTypeSection(entry.key, entry.value))
                    .toList(),
              ],
            );
          }
        },
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}