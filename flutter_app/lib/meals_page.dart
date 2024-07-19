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
  late Future<List<UserMeal>> futureUserMeals;

  @override
  void initState() {
    super.initState();
    futureUserMeals = apiService.fetchUserMeals();
  }

  List<UserMeal> _filterMealsByToday(List<UserMeal> meals) {
    DateTime now = DateTime.now();
    return meals.where((meal) {
      return meal.datetime.year == now.year &&
             meal.datetime.month == now.month &&
             meal.datetime.day == now.day;
    }).toList();
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(double.tryParse(quantityController.text));
              },
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
    }
  }

  void _deleteMeal(int mealId) async {
    await apiService.deleteUserMeal(mealId);
    setState(() {
      futureUserMeals = apiService.fetchUserMeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals'),
      ),
      body: FutureBuilder<List<UserMeal>>(
        future: futureUserMeals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No meals found.'));
          } else {
            List<UserMeal> todayMeals = _filterMealsByToday(snapshot.data!);
            if (todayMeals.isEmpty) {
              return const Center(child: Text('No meals found for today.'));
            } else {
              return ListView(
                children: todayMeals.map((userMeal) {
                  return ListTile(
                    title: Text(userMeal.foodItem.name),
                    subtitle: Text('${userMeal.quantity} ${userMeal.foodItem.quantityUnit} at ${DateFormat('HH:mm').format(userMeal.datetime)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editMeal(userMeal),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteMeal(userMeal.id),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }
          }
        },
      ),
    );
  }
}
