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
    futureTodayUserMeals = apiService.fetchTodayUserMeals(context);
    futureUserProfile = apiService.fetchUserProfile(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Tracker'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: CircularProgressIndicator(
                      value: calorieProgress,
                      strokeWidth: 12,
                      backgroundColor: colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(calorieProgress * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        'of daily goal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${totalCalories.toStringAsFixed(0)} / ${targetCalories.toStringAsFixed(0)} kcal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Macronutrients',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NutrientProgressCircle(
                  label: 'Fat',
                  progress: fatProgress,
                  total: totalFat,
                  target: targetFat,
                  color: colorScheme.tertiary,
                ),
                NutrientProgressCircle(
                  label: 'Carbs',
                  progress: carbProgress,
                  total: totalCarbs,
                  target: targetCarbs,
                  color: colorScheme.secondary,
                ),
                NutrientProgressCircle(
                  label: 'Protein',
                  progress: proteinProgress,
                  total: totalProtein,
                  target: targetProtein,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NutrientProgressCircle extends StatelessWidget {
  final String label;
  final double progress;
  final double total;
  final double target;
  final Color color;

  const NutrientProgressCircle({
    Key? key,
    required this.label,
    required this.progress,
    required this.total,
    required this.target,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SizedBox(
            height: 80,
            width: 80,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${total.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} g',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}