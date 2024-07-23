import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for food',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchFoodItems,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToAddFoodItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text(
                'Create your own food',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : Expanded(
                        child: ListView.builder(
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

  @override
  void initState() {
    super.initState();
    _portionSizeController.text = widget.foodItem.portionSize.toString();
    _selectedUnit = widget.foodItem.quantityUnit;
  }

  void _addMeal() async {
    try {
      await apiService.addUserMeal(widget.foodItem.id, double.parse(_portionSizeController.text));
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
        title: Text('${widget.foodItem.name} Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${widget.foodItem.name}', style: const TextStyle(fontSize: 18)),
            Text('Producer: ${widget.foodItem.producer}', style: const TextStyle(fontSize: 18)),
            Text('Calories: ${widget.foodItem.calories} kcal', style: const TextStyle(fontSize: 18)),
            Text('Protein: ${widget.foodItem.protein} g', style: const TextStyle(fontSize: 18)),
            Text('Fat: ${widget.foodItem.fat} g', style: const TextStyle(fontSize: 18)),
            Text('Carbohydrates: ${widget.foodItem.carbohydrates} g', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _portionSizeController,
                    decoration: const InputDecoration(
                      labelText: 'Portion Size',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Text(widget.foodItem.quantityUnit, style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMeal,
              child: const Text('Add Meal'),
            ),
          ],
        ),
      ),
    );
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: _producerController,
                decoration: const InputDecoration(
                  labelText: 'Producer',
                ),
              ),
              TextField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _proteinController,
                decoration: const InputDecoration(
                  labelText: 'Protein (optional)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _fatController,
                decoration: const InputDecoration(
                  labelText: 'Fat (optional)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _carbohydratesController,
                decoration: const InputDecoration(
                  labelText: 'Carbohydrates (optional)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _portionSizeController,
                decoration: const InputDecoration(
                  labelText: 'Portion Size',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              const Text('Quantity Unit'),
              DropdownButton<String>(
                value: _selectedUnit,
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addFoodItem,
                child: const Text('Add Food Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
