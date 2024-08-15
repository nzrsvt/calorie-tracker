import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  late AnimationController _aiButtonController;

  @override
  void initState() {
    super.initState();
    _aiButtonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _aiButtonController.dispose();
    super.dispose();
  }

  void _searchFoodItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<FoodItem> results = await apiService.searchFoodItems(_searchController.text);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load search results';
        _isLoading = false;
      });
    }
  }

  void _navigateToAiAddFoodItem() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AiAddFoodItemPage()),
    );
  }

  void _navigateToFoodDetail(FoodItem foodItem) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoodDetailPage(foodItem: foodItem)),
    );
  }

  void _navigateToAddFoodItem() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFoodItemPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchBar(
              controller: _searchController,
              hintText: 'Search for food',
              onSubmitted: (_) => _searchFoodItems(),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchFoodItems,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _navigateToAddFoodItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Create your own food'),
                ),
                const SizedBox(width: 16),
                AnimatedBuilder(
                  animation: _aiButtonController,
                  builder: (context, child) {
                    return FilledButton(
                      onPressed: _navigateToAiAddFoodItem,
                      style: FilledButton.styleFrom(
                        backgroundColor: HSLColor.fromAHSL(
                          1.0,
                          _aiButtonController.value * 360.0,
                          0.5,
                          0.5,
                        ).toColor(),
                      ),
                      child: const Text('AI'),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            FoodItem foodItem = _searchResults[index];
                            return ListTile(
                              title: Text(foodItem.name),
                              subtitle: Text('Producer: ${foodItem.producer}, Calories: ${foodItem.calories} kcal'),
                              onTap: () => _navigateToFoodDetail(foodItem),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodDetailPage extends StatefulWidget {
  final FoodItem foodItem;

  const FoodDetailPage({super.key, required this.foodItem});

  @override
  _FoodDetailPageState createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final ApiService apiService = ApiService();
  final TextEditingController _portionSizeController = TextEditingController();
  String _selectedUnit = '';
  String _selectedMealType = 'breakfast'; // Додано: початкове значення для типу прийому їжі

  @override
  void initState() {
    super.initState();
    _portionSizeController.text = widget.foodItem.portionSize.toString();
    _selectedUnit = widget.foodItem.quantityUnit;
  }

  void _addMeal() async {
    try {
      await apiService.addUserMeal(
        widget.foodItem.id,
        double.parse(_portionSizeController.text),
        _selectedMealType // Додано: передаємо вибраний тип прийому їжі
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal added successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add meal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodItem.name),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Producer: ${widget.foodItem.producer}', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text('Calories: ${widget.foodItem.calories} kcal', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text('Protein: ${widget.foodItem.protein} g', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text('Fat: ${widget.foodItem.fat} g', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text('Carbohydrates: ${widget.foodItem.carbohydrates} g', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portionSizeController,
              decoration: InputDecoration(
                labelText: 'Portion Size',
                suffixText: widget.foodItem.quantityUnit,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMealType,
              decoration: const InputDecoration(labelText: 'Meal Type'),
              items: <String>[
                'breakfast',
                'morning_snack',
                'lunch',
                'afternoon_snack',
                'dinner',
                'evening_snack'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.replaceAll('_', ' ').capitalize()),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedMealType = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _addMeal,
              child: const Text('Add Meal'),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class AddFoodItemPage extends StatefulWidget {
  const AddFoodItemPage({super.key});

  @override
  _AddFoodItemPageState createState() => _AddFoodItemPageState();
}

class _AddFoodItemPageState extends State<AddFoodItemPage> {
  final ApiService apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _producerController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbohydratesController = TextEditingController();
  final TextEditingController _portionSizeController = TextEditingController();
  String _selectedUnit = 'g';

  void _addFoodItem() async {
    try {
      await apiService.addFoodItem(
        name: _nameController.text,
        producer: _producerController.text,
        calories: int.parse(_caloriesController.text),
        protein: double.tryParse(_proteinController.text),
        fat: double.tryParse(_fatController.text),
        carbohydrates: double.tryParse(_carbohydratesController.text),
        portionSize: double.parse(_portionSizeController.text),
        quantityUnit: _selectedUnit,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Food item added successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add food item')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food Item'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _producerController,
              decoration: const InputDecoration(labelText: 'Producer'),
            ),
            TextField(
              controller: _caloriesController,
              decoration: const InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _proteinController,
              decoration: const InputDecoration(labelText: 'Protein (optional)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _fatController,
              decoration: const InputDecoration(labelText: 'Fat (optional)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _carbohydratesController,
              decoration: const InputDecoration(labelText: 'Carbohydrates (optional)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _portionSizeController,
              decoration: const InputDecoration(labelText: 'Portion Size'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              decoration: const InputDecoration(labelText: 'Quantity Unit'),
              items: <String>['g', 'ml', 'pcs'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedUnit = newValue!;
                });
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _addFoodItem,
              child: const Text('Add Food Item'),
            ),
          ],
        ),
      ),
    );
  }
}

class AiAddFoodItemPage extends StatefulWidget {
  const AiAddFoodItemPage({super.key});

  @override
  _AiAddFoodItemPageState createState() => _AiAddFoodItemPageState();
}

class _AiAddFoodItemPageState extends State<AiAddFoodItemPage> {
  final ApiService apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  double? _calories;
  double? _protein;
  double? _fat;
  double? _carbohydrates;
  bool _isLoading = false;
  String _errorMessage = '';

  void _calculateNutritionalValue() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      Map<String, dynamic> nutritionalData = await apiService.calculateNutritionalValue(_descriptionController.text);
      setState(() {
        _calories = nutritionalData['calories'];
        _protein = nutritionalData['protein'];
        _fat = nutritionalData['fat'];
        _carbohydrates = nutritionalData['carbohydrates'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to calculate nutritional value';
        _isLoading = false;
      });
    }
  }

  void _addFoodItem() async {
    try {
      await apiService.addFoodItem(
        name: _nameController.text,
        producer: 'AI-generated',
        calories: _calories?.toInt() ?? 0,
        protein: _protein ?? 0,
        fat: _fat ?? 0,
        carbohydrates: _carbohydrates ?? 0,
        portionSize: 100,
        quantityUnit: 'g',
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Food item added successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add food item')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI-generated Food Item'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _calculateNutritionalValue,
              child: const Text('AI Calculation of Nutritional Value'),
            ),
            if (_calories != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Calories: $_calories kcal', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text('Protein: $_protein g', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text('Fat: $_fat g', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text('Carbohydrates: $_carbohydrates g', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (_errorMessage.isNotEmpty)
              Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red))),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _addFoodItem,
              child: const Text('Add Food Item'),
            ),
          ],
        ),
      ),
    );
  }
}
