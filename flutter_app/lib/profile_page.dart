import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService apiService = ApiService();
  late Future<UserProfile> futureUserProfile;

  @override
  void initState() {
    super.initState();
    futureUserProfile = apiService.fetchUserProfile();
  }

  void _editUserProfile(UserProfile profile) async {
    final TextEditingController genderController = TextEditingController(text: profile.gender);
    final TextEditingController ageController = TextEditingController(text: profile.age.toString());
    final TextEditingController heightController = TextEditingController(text: profile.height.toString());
    final TextEditingController weightController = TextEditingController(text: profile.weight.toString());
    final TextEditingController activityLevelController = TextEditingController(text: profile.activityLevel);
    final TextEditingController goalController = TextEditingController(text: profile.goal);

    final result = await showDialog<UserProfile>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: genderController,
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age'),
                ),
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                ),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                ),
                TextField(
                  controller: activityLevelController,
                  decoration: const InputDecoration(labelText: 'Activity Level'),
                ),
                TextField(
                  controller: goalController,
                  decoration: const InputDecoration(labelText: 'Goal'),
                ),
              ],
            ),
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
                UserProfile updatedProfile = UserProfile(
                  id: profile.id,
                  username: profile.username,
                  email: profile.email,
                  gender: genderController.text,
                  age: int.tryParse(ageController.text) ?? profile.age,
                  height: int.tryParse(heightController.text) ?? profile.height,
                  weight: double.tryParse(weightController.text) ?? profile.weight,
                  activityLevel: activityLevelController.text,
                  goal: goalController.text,
                  calorieIntake: profile.calorieIntake,
                  proteinIntake: profile.proteinIntake,
                  fatIntake: profile.fatIntake,
                  carbohydrateIntake: profile.carbohydrateIntake,
                );
                Navigator.of(context).pop(updatedProfile);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await apiService.updateUserProfile(result);
      setState(() {
        futureUserProfile = apiService.fetchUserProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<UserProfile>(
        future: futureUserProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No user profile found.'));
          } else {
            UserProfile userProfile = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gender: ${userProfile.gender}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Age: ${userProfile.age}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Height: ${userProfile.height} cm', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Weight: ${userProfile.weight} kg', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Activity Level: ${userProfile.activityLevel}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Goal: ${userProfile.goal}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _editUserProfile(userProfile),
                    child: const Text('Edit Profile'),
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
