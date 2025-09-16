import 'package:flutter/material.dart';
import 'dart:io';
import '../services/camera_service.dart';
import '../services/groq_service.dart';
import '../services/storage_service.dart';
import '../models/meal.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService.instance;
  final GroqService _groqService = GroqService.instance;
  final StorageService _storageService = StorageService.instance;
  final TextEditingController _descriptionController = TextEditingController();
  
  File? _capturedPhoto;
  bool _isProcessing = false;
  Map<String, dynamic>? _estimatedMacros;
  
  // Mock user ID for MVP
  final String _userId = 'user123';
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    try {
      await _cameraService.initialize();
      await _groqService.initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize services: $e')),
        );
      }
    }
  }
  
  Future<void> _takePhoto() async {
    try {
      final photo = await _cameraService.takePhoto();
      if (photo != null) {
        setState(() {
          _capturedPhoto = photo;
          _estimatedMacros = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take photo: $e')),
        );
      }
    }
  }
  
  Future<void> _pickFromGallery() async {
    try {
      final photo = await _cameraService.pickFromGallery();
      if (photo != null) {
        setState(() {
          _capturedPhoto = photo;
          _estimatedMacros = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick photo: $e')),
        );
      }
    }
  }
  
  Future<void> _estimateMacros() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a food description')),
      );
      return;
    }
    
    setState(() => _isProcessing = true);
    
    try {
      final macros = await _groqService.estimateMacros(_descriptionController.text.trim());
      setState(() {
        _estimatedMacros = macros;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to estimate macros: $e')),
        );
      }
    }
  }
  
  Future<void> _saveMeal() async {
    if (_capturedPhoto == null || _estimatedMacros == null) {
      return;
    }
    
    setState(() => _isProcessing = true);
    
    try {
      // Upload photo
      final photoUrl = await _storageService.uploadPhoto(_capturedPhoto!, _userId);
      
      // Create meal object
      final meal = Meal(
        id: '', // Will be set by Firestore
        userId: _userId,
        photoUrl: photoUrl,
        description: _descriptionController.text.trim(),
        kcal: _estimatedMacros!['kcal'] ?? 0,
        protein: (_estimatedMacros!['protein'] ?? 0).toDouble(),
        carbs: (_estimatedMacros!['carbs'] ?? 0).toDouble(),
        fat: (_estimatedMacros!['fat'] ?? 0).toDouble(),
        createdAt: DateTime.now(),
      );
      
      // Save to database
      await _storageService.saveMeal(meal);
      
      setState(() => _isProcessing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal saved successfully!')),
        );
        Navigator.of(context).pop(true); // Return to home screen
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save meal: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodSnap'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo section
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _capturedPhoto != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          _capturedPhoto!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No photo selected',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Camera buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Description input
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'What did you eat?',
                hintText: 'e.g., Menemen with bread, Turkish tea',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            // Estimate button
            ElevatedButton(
              onPressed: _isProcessing ? null : _estimateMacros,
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Estimate Macros'),
            ),
            
            const SizedBox(height: 16),
            
            // Macros display
            if (_estimatedMacros != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated Macros',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MacroDisplay(
                            label: 'Kcal',
                            value: _estimatedMacros!['kcal'].toString(),
                            color: Colors.orange,
                          ),
                          _MacroDisplay(
                            label: 'Protein',
                            value: '${_estimatedMacros!['protein']}g',
                            color: Colors.red,
                          ),
                          _MacroDisplay(
                            label: 'Carbs',
                            value: '${_estimatedMacros!['carbs']}g',
                            color: Colors.blue,
                          ),
                          _MacroDisplay(
                            label: 'Fat',
                            value: '${_estimatedMacros!['fat']}g',
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Save button
              ElevatedButton(
                onPressed: (_capturedPhoto != null && _estimatedMacros != null && !_isProcessing)
                    ? _saveMeal
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Meal'),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}

class _MacroDisplay extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  
  const _MacroDisplay({
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}