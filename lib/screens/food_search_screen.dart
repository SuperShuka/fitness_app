import 'package:flutter/material.dart';
import 'package:fitness_app/models/food_item.dart';
import 'package:fitness_app/services/nutrition_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class FoodSearchScreen extends StatefulWidget {
  @override
  _FoodSearchScreenState createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final NutritionService _nutritionService = NutritionService();
  List<FoodItem> _searchResults = [];
  List<FoodItem> _recentFoods = [];
  List<FoodItem> _favoriteItems = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRecentAndFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentAndFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recent = await _nutritionService.getRecentFoods();
      final favorites = await _nutritionService.getFavoriteFoods();

      setState(() {
        _recentFoods = recent;
        _favoriteItems = favorites;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading recent and favorite foods: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchFood(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    try {
      final results = await _nutritionService.searchFoods(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error searching foods: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(FoodItem foodItem) async {
    final updatedItem = FoodItem(
      id: foodItem.id,
      name: foodItem.name,
      calories: foodItem.calories,
      protein: foodItem.protein,
      carbs: foodItem.carbs,
      fat: foodItem.fat,
      isFavorite: !foodItem.isFavorite,
      barcode: foodItem.barcode,
    );

    await _nutritionService.updateFoodItem(updatedItem);

    setState(() {
      if (_isSearching) {
        final index = _searchResults.indexWhere((item) => item.id == foodItem.id);
        if (index != -1) {
          _searchResults[index] = updatedItem;
        }
      }

      if (updatedItem.isFavorite) {
        _favoriteItems.add(updatedItem);
      } else {
        _favoriteItems.removeWhere((item) => item.id == foodItem.id);
      }
    });
  }

  void _addCustomFood() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddCustomFoodForm(
        onFoodAdded: (FoodItem newFood) {
          Navigator.pop(context);
          Navigator.pop(context, newFood);
        },
      ),
    );
  }

  void _scanBarcode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Barcode scanning will be implemented later')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Food'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for food...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _searchFood,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isSearching
          ? _buildSearchResults()
          : _buildRecentAndFavorites(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'scan',
            onPressed: _scanBarcode,
            backgroundColor: Colors.amber,
            child: Icon(Icons.qr_code_scanner),
            mini: true,
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _addCustomFood,
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          _isLoading
              ? 'Searching...'
              : 'No results found. Try different keywords or add a custom food.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        return _buildFoodItem(food);
      },
    );
  }

  Widget _buildRecentAndFavorites() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentFoods.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Recent',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _recentFoods.length,
              itemBuilder: (context, index) {
                return _buildFoodItem(_recentFoods[index]);
              },
            ),
          ],
          if (_favoriteItems.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Favorites',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _favoriteItems.length,
              itemBuilder: (context, index) {
                return _buildFoodItem(_favoriteItems[index]);
              },
            ),
          ],
          if (_recentFoods.isEmpty && _favoriteItems.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Search for food or add a custom item',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(FoodItem food) {
    return ListTile(
      // leading: CircleAvatar(
      //   backgroundColor: Colors.blue[100],
      //   child: food.imageUrl != null
      //       ? ClipOval(
      //     child: Image.network(
      //       food.imageUrl!,
      //       width: 40,
      //       height: 40,
      //       fit: BoxFit.cover,
      //       errorBuilder: (context, error, stackTrace) {
      //         return Icon(Icons.restaurant);
      //       },
      //     ),
      //   )
      //       : Icon(Icons.restaurant),
      // ),
      title: Text(food.name),
      subtitle: Text(
        'P: ${food.protein.toStringAsFixed(1)}g  '
            'C: ${food.carbs.toStringAsFixed(1)}g  '
            'F: ${food.fat.toStringAsFixed(1)}g',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${food.calories.toInt()} kcal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 16),
          IconButton(
            icon: Icon(
              food.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: food.isFavorite ? Colors.red : null,
            ),
            onPressed: () => _toggleFavorite(food),
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context, food);
      },
    );
  }
}

class _AddCustomFoodForm extends StatefulWidget {
  final Function(FoodItem) onFoodAdded;

  const _AddCustomFoodForm({
    Key? key,
    required this.onFoodAdded,
  }) : super(key: key);

  @override
  __AddCustomFoodFormState createState() => __AddCustomFoodFormState();
}

class __AddCustomFoodFormState extends State<_AddCustomFoodForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _saveFood() {
    if (_formKey.currentState!.validate()) {
      final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final newFood = FoodItem(
        id: 'custom_${const Uuid().v4()}',
        name: _nameController.text.trim(),
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        fat: double.parse(_fatController.text),
        isFavorite: false,
      );

      FirebaseFirestore.instance
          .collection('custom_foods')
          .doc(newFood.id)
          .set({
        ...newFood.toMap(),
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      widget.onFoodAdded(newFood);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Custom Food',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Food Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _caloriesController,
                      decoration: InputDecoration(
                        labelText: 'Calories',
                        border: OutlineInputBorder(),
                        suffixText: 'kcal',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      decoration: InputDecoration(
                        labelText: 'Protein',
                        border: OutlineInputBorder(),
                        suffixText: 'g',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      decoration: InputDecoration(
                        labelText: 'Carbs',
                        border: OutlineInputBorder(),
                        suffixText: 'g',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      decoration: InputDecoration(
                        labelText: 'Fat',
                        border: OutlineInputBorder(),
                        suffixText: 'g',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveFood,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Save Food',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}