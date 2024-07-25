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
  late Future<List<UserMeal>> futureUserMeals;
  late Future<UserProfile> futureUserProfile;

  @override
  void initState() {
    super.initState();
    futureUserMeals = apiService.fetchUserMeals();
    futureUserProfile = apiService.fetchUserProfile(); // Fetch user profile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Tracker'),
      ),
      body: FutureBuilder(
        future: Future.wait([futureUserMeals, futureUserProfile]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<UserMeal> userMeals = snapshot.data![0];
            UserProfile userProfile = snapshot.data![1];

            double totalCalories = userMeals.fold(0, (sum, meal) => sum + meal.portionCalories);
            double totalFat = userMeals.fold(0, (sum, meal) => sum + meal.portionFat);
            double totalCarbohydrates = userMeals.fold(0, (sum, meal) => sum + meal.portionCarbohydrates);
            double totalProteins = userMeals.fold(0, (sum, meal) => sum + meal.portionProteins);

            double calorieProgress = totalCalories / userProfile.calorieIntake;
            double fatProgress = totalFat / userProfile.fatIntake;
            double carbProgress = totalCarbohydrates / userProfile.carbohydrateIntake;
            double proteinProgress = totalProteins / userProfile.proteinIntake;

            return Column(
              children: [
                Flexible(
                  flex: 1,
                  child: Center(
                    child: CircularProgressIndicatorWithText(
                      value: calorieProgress,
                      text: '${totalCalories.toStringAsFixed(0)}/${userProfile.calorieIntake.toStringAsFixed(0)} kcal',
                      label: 'Calories',
                      size: 100.0, // Розмір круга
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircularProgressIndicatorWithText(
                        value: fatProgress,
                        text: '${totalFat.toStringAsFixed(0)}/${userProfile.fatIntake.toStringAsFixed(0)} g',
                        label: 'Fat',
                        size: 80.0, // Розмір круга
                      ),
                      CircularProgressIndicatorWithText(
                        value: carbProgress,
                        text: '${totalCarbohydrates.toStringAsFixed(0)}/${userProfile.carbohydrateIntake.toStringAsFixed(0)} g',
                        label: 'Carbs',
                        size: 80.0, // Розмір круга
                      ),
                      CircularProgressIndicatorWithText(
                        value: proteinProgress,
                        text: '${totalProteins.toStringAsFixed(0)}/${userProfile.proteinIntake.toStringAsFixed(0)} g',
                        label: 'Proteins',
                        size: 80.0, // Розмір круга
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class CircularProgressIndicatorWithText extends StatelessWidget {
  final double value;
  final String text;
  final String label;
  final double size;

  const CircularProgressIndicatorWithText({
    required this.value,
    required this.text,
    required this.label,
    required this.size, // Доданий параметр для розміру
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: size,
              width: size,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 8.0, // Товщина круга
              ),
            ),
            Text(text, style: const TextStyle(fontSize: 16)), // Розмір тексту
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 20)), // Розмір підпису
      ],
    );
  }
}
