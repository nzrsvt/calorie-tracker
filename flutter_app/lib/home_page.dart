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
  late Future<List<UserMeal>> futureTodayUserMeals;
  late Future<UserProfile> futureUserProfile;

  @override
  void initState() {
    super.initState();
    futureTodayUserMeals = apiService.fetchTodayUserMeals();
    futureUserProfile = apiService.fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Tracker'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: Future.wait([futureTodayUserMeals, futureUserProfile]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<UserMeal> todayUserMeals = snapshot.data![0];
            UserProfile userProfile = snapshot.data![1];

            double totalCalories = todayUserMeals.fold(0, (sum, meal) => sum + meal.portionCalories);
            double totalFat = todayUserMeals.fold(0, (sum, meal) => sum + meal.portionFat);
            double totalCarbohydrates = todayUserMeals.fold(0, (sum, meal) => sum + meal.portionCarbohydrates);
            double totalProteins = todayUserMeals.fold(0, (sum, meal) => sum + meal.portionProteins);

            double calorieProgress = totalCalories / userProfile.calorieIntake;
            double fatProgress = totalFat / userProfile.fatIntake;
            double carbProgress = totalCarbohydrates / userProfile.carbohydrateIntake;
            double proteinProgress = totalProteins / userProfile.proteinIntake;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Summary',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: NutritionProgressCard(
                      calorieProgress: calorieProgress,
                      totalCalories: totalCalories,
                      targetCalories: userProfile.calorieIntake,
                      fatProgress: fatProgress,
                      totalFat: totalFat,
                      targetFat: userProfile.fatIntake,
                      carbProgress: carbProgress,
                      totalCarbs: totalCarbohydrates,
                      targetCarbs: userProfile.carbohydrateIntake,
                      proteinProgress: proteinProgress,
                      totalProtein: totalProteins,
                      targetProtein: userProfile.proteinIntake,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class NutritionProgressCard extends StatelessWidget {
  final double calorieProgress;
  final double totalCalories;
  final double targetCalories;
  final double fatProgress;
  final double totalFat;
  final double targetFat;
  final double carbProgress;
  final double totalCarbs;
  final double targetCarbs;
  final double proteinProgress;
  final double totalProtein;
  final double targetProtein;

  const NutritionProgressCard({
    Key? key,
    required this.calorieProgress,
    required this.totalCalories,
    required this.targetCalories,
    required this.fatProgress,
    required this.totalFat,
    required this.targetFat,
    required this.carbProgress,
    required this.totalCarbs,
    required this.targetCarbs,
    required this.proteinProgress,
    required this.totalProtein,
    required this.targetProtein,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: calorieProgress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${totalCalories.toStringAsFixed(0)} / ${targetCalories.toStringAsFixed(0)} kcal',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Macronutrients',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: NutrientProgressIndicator(
                    label: 'Fat',
                    progress: fatProgress,
                    total: totalFat,
                    target: targetFat,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: NutrientProgressIndicator(
                    label: 'Carbs',
                    progress: carbProgress,
                    total: totalCarbs,
                    target: targetCarbs,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: NutrientProgressIndicator(
                    label: 'Protein',
                    progress: proteinProgress,
                    total: totalProtein,
                    target: targetProtein,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NutrientProgressIndicator extends StatelessWidget {
  final String label;
  final double progress;
  final double total;
  final double target;
  final Color color;

  const NutrientProgressIndicator({
    Key? key,
    required this.label,
    required this.progress,
    required this.total,
    required this.target,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 8),
        Text(
          '${total.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} g',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
