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
    futureTodayUserMeals = apiService.fetchTodayUserMeals();
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
      setState(() {
        meal.quantity = result;
      });
      await apiService.updateUserMeal(meal);
      setState(() {
        futureTodayUserMeals = apiService.fetchTodayUserMeals();
      });
    }
  }

  void _deleteMeal(int mealId) async {
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
      await apiService.deleteUserMeal(mealId);
      setState(() {
        futureTodayUserMeals = apiService.fetchTodayUserMeals();
      });
    }
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
            return ListView.builder(
              itemCount: todayMeals.length,
              itemBuilder: (context, index) {
                UserMeal userMeal = todayMeals[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(userMeal.foodItem.name, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(
                      '${userMeal.quantity} ${userMeal.foodItem.quantityUnit}, ${userMeal.portionCalories} kcal\n${DateFormat('HH:mm').format(userMeal.datetime)}',
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
                          onPressed: () => _deleteMeal(userMeal.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
