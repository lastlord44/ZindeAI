import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/storage_service.dart';
import 'camera_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService.instance;
  List<Meal> _todayMeals = [];
  bool _isLoading = true;
  
  // Mock user ID for MVP
  final String _userId = 'user123';
  
  @override
  void initState() {
    super.initState();
    _loadTodayMeals();
  }
  
  Future<void> _loadTodayMeals() async {
    try {
      setState(() => _isLoading = true);
      final meals = await _storageService.getUserMeals(_userId, date: DateTime.now());
      setState(() {
        _todayMeals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading meals: $e')),
        );
      }
    }
  }
  
  int get _totalKcal => _todayMeals.fold(0, (sum, meal) => sum + meal.kcal);
  double get _totalProtein => _todayMeals.fold(0.0, (sum, meal) => sum + meal.protein);
  double get _totalCarbs => _todayMeals.fold(0.0, (sum, meal) => sum + meal.carbs);
  double get _totalFat => _todayMeals.fold(0.0, (sum, meal) => sum + meal.fat);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZindeAI MVP v1.8'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Daily summary card
                Card(
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Summary',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _MacroChip(label: 'Kcal', value: _totalKcal.toString(), color: Colors.orange),
                            _MacroChip(label: 'Protein', value: '${_totalProtein.toStringAsFixed(1)}g', color: Colors.red),
                            _MacroChip(label: 'Carbs', value: '${_totalCarbs.toStringAsFixed(1)}g', color: Colors.blue),
                            _MacroChip(label: 'Fat', value: '${_totalFat.toStringAsFixed(1)}g', color: Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Meals list
                Expanded(
                  child: _todayMeals.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No meals logged today',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap the + button to add your first meal!',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _todayMeals.length,
                          itemBuilder: (context, index) {
                            final meal = _todayMeals[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: meal.photoUrl.isNotEmpty 
                                      ? NetworkImage(meal.photoUrl) 
                                      : null,
                                  child: meal.photoUrl.isEmpty 
                                      ? const Icon(Icons.restaurant) 
                                      : null,
                                ),
                                title: Text(meal.description),
                                subtitle: Text(
                                  '${meal.kcal} kcal • P: ${meal.protein.toStringAsFixed(1)}g • C: ${meal.carbs.toStringAsFixed(1)}g • F: ${meal.fat.toStringAsFixed(1)}g',
                                ),
                                trailing: Text(
                                  _formatTime(meal.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CameraScreen()),
          );
          if (result == true) {
            _loadTodayMeals(); // Refresh meals list
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
  
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  
  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}