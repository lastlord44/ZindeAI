import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/meal.dart';

/// Home screen showing daily meal timeline and nutrition summary
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Meal> _todaysMeals = [];
  Map<String, double> _dailyTotals = {
    'kcal': 0,
    'protein': 0,
    'carbs': 0,
    'fat': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodaysMeals();
  }

  Future<void> _loadTodaysMeals() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Get actual user ID from authentication
    const userId = 'demo_user';
    
    try {
      final meals = await StorageService.getUserMeals(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );

      final totals = await StorageService.getDailyTotals(
        userId: userId,
        date: DateTime.now(),
      );

      setState(() {
        _todaysMeals = meals.map((data) => Meal.fromJson(data)).toList();
        _dailyTotals = totals;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading meals: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Nutrition'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTodaysMeals,
              child: Column(
                children: [
                  _buildNutritionSummary(),
                  Expanded(
                    child: _buildMealsList(),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to camera screen
          debugPrint('Navigate to camera screen');
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildNutritionSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Daily Totals',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNutrientCard('Calories', _dailyTotals['kcal']!.toInt(), 'kcal'),
              _buildNutrientCard('Protein', _dailyTotals['protein']!.toInt(), 'g'),
              _buildNutrientCard('Carbs', _dailyTotals['carbs']!.toInt(), 'g'),
              _buildNutrientCard('Fat', _dailyTotals['fat']!.toInt(), 'g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientCard(String label, int value, String unit) {
    return Column(
      children: [
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(unit, style: Theme.of(context).textTheme.bodySmall),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildMealsList() {
    if (_todaysMeals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No meals tracked today',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the camera button to add your first meal!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _todaysMeals.length,
      itemBuilder: (context, index) {
        final meal = _todaysMeals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: meal.photoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      meal.photoUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant),
                  ),
            title: Text(meal.description),
            subtitle: Text(
              '${meal.kcal.toInt()} kcal • P: ${meal.protein.toInt()}g • C: ${meal.carbs.toInt()}g • F: ${meal.fat.toInt()}g',
            ),
            trailing: Text(
              '${meal.createdAt.hour}:${meal.createdAt.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }
}