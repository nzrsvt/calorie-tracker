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

  void _editField(UserProfile profile, String field, String fieldType) async {
    TextEditingController controller = TextEditingController();
    String dropdownValue = '';

    if (fieldType == 'number') {
      if (field == 'age') controller.text = profile.age.toString();
      if (field == 'height') controller.text = profile.height.toString();
      if (field == 'weight') controller.text = profile.weight.toString();
    } else if (fieldType == 'dropdown') {
      if (field == 'gender') dropdownValue = profile.gender;
      if (field == 'activityLevel') dropdownValue = profile.activityLevel;
      if (field == 'goal') dropdownValue = profile.goal;
    }

    final result = await showDialog<UserProfile>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit $field'),
              content: SingleChildScrollView(
                child: fieldType == 'number'
                    ? Column(
                        children: [
                          TextField(
                            controller: controller,
                            keyboardType: field == 'weight' 
                                ? const TextInputType.numberWithOptions(decimal: true)
                                : TextInputType.number,
                            decoration: InputDecoration(labelText: field),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    double currentValue = double.tryParse(controller.text) ?? 0;
                                    controller.text = (currentValue - 1).toStringAsFixed(field == 'weight' ? 1 : 0);
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    double currentValue = double.tryParse(controller.text) ?? 0;
                                    controller.text = (currentValue + 1).toStringAsFixed(field == 'weight' ? 1 : 0);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      )
                    : DropdownButton<String>(
                        value: dropdownValue,
                        items: (field == 'gender'
                                ? ['M', 'F']
                                : field == 'activityLevel'
                                    ? ['S', 'L', 'M', 'V', 'E']
                                    : ['L', 'M', 'G'])
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(_getFullText(field, value)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    UserProfile updatedProfile = UserProfile(
                      id: profile.id,
                      username: profile.username,
                      email: profile.email,
                      gender: field == 'gender' ? dropdownValue : profile.gender,
                      age: field == 'age' ? int.tryParse(controller.text) ?? profile.age : profile.age,
                      height: field == 'height' ? int.tryParse(controller.text) ?? profile.height : profile.height,
                      weight: field == 'weight' ? double.tryParse(controller.text) ?? profile.weight : profile.weight,
                      activityLevel: field == 'activityLevel' ? dropdownValue : profile.activityLevel,
                      goal: field == 'goal' ? dropdownValue : profile.goal,
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
      },
    );

    if (result != null) {
      try {
        await apiService.updateUserProfile(result);
        setState(() {
          futureUserProfile = apiService.fetchUserProfile();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  String _getFullText(String field, String value) {
    switch (field) {
      case 'gender':
        return value == 'M' ? 'Male' : 'Female';
      case 'activityLevel':
        switch (value) {
          case 'S': return 'Sedentary';
          case 'L': return 'Lightly active';
          case 'M': return 'Moderately active';
          case 'V': return 'Very active';
          case 'E': return 'Extra active';
          default: return value;
        }
      case 'goal':
        switch (value) {
          case 'L': return 'Weight loss';
          case 'M': return 'Weight maintenance';
          case 'G': return 'Weight gain';
          default: return value;
        }
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
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
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _buildListTile('Gender', _getFullText('gender', userProfile.gender), () => _editField(userProfile, 'gender', 'dropdown')),
                _buildListTile('Age', '${userProfile.age} years', () => _editField(userProfile, 'age', 'number')),
                _buildListTile('Height', '${userProfile.height} cm', () => _editField(userProfile, 'height', 'number')),
                _buildListTile('Weight', '${userProfile.weight} kg', () => _editField(userProfile, 'weight', 'number')),
                _buildListTile('Activity Level', _getFullText('activityLevel', userProfile.activityLevel), () => _editField(userProfile, 'activityLevel', 'dropdown')),
                _buildListTile('Goal', _getFullText('goal', userProfile.goal), () => _editField(userProfile, 'goal', 'dropdown')),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Nutrition Goals',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _buildListTile('Calorie Intake', '${userProfile.calorieIntake.toStringAsFixed(1)} kcal', null),
                _buildListTile('Protein Intake', '${userProfile.proteinIntake.toStringAsFixed(1)} g', null),
                _buildListTile('Fat Intake', '${userProfile.fatIntake.toStringAsFixed(1)} g', null),
                _buildListTile('Carbohydrate Intake', '${userProfile.carbohydrateIntake.toStringAsFixed(1)} g', null),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildListTile(String title, String value, VoidCallback? onEdit) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      trailing: onEdit != null ? IconButton(
        icon: const Icon(Icons.edit_outlined),
        onPressed: onEdit,
      ) : null,
    );
  }
}
