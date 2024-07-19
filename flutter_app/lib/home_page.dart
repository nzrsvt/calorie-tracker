import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ApiService apiService = ApiService();
  late Future<List<FoodItem>> futureFoodItems;
  late Future<List<UserMeal>> futureUserMeals;

  @override
  void initState() {
    super.initState();
    futureFoodItems = apiService.fetchFoodItems();
    futureUserMeals = apiService.fetchUserMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Tracker'),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: FutureBuilder<List<FoodItem>>(
              future: futureFoodItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return ListView(
                    children: snapshot.data!.map((foodItem) {
                      return ListTile(
                        title: Text('${foodItem.producer} ${foodItem.name}'),
                        subtitle: Text('${foodItem.calories} kcal'),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
          Flexible(
            flex: 1,
            child: FutureBuilder<List<UserMeal>>(
              future: futureUserMeals,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return ListView(
                    children: snapshot.data!.map((userMeal) {
                      return ListTile(
                        title: Text(userMeal.foodItem.name),
                        subtitle: Text('${userMeal.quantity} ${userMeal.foodItem.quantityUnit} at ${userMeal.datetime}'),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

