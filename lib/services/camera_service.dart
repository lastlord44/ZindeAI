import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();
  
  /// Kamera veya galeriden görsel seçimi
  static Future<File?> pickImage({
    required ImageSource source,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: 2048, // Ön sınırlama için
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('[CameraService] Error: $e');
      return null;
    }
  }
  
  /// Batch görsel seçimi (galeri için)
  static Future<List<File>> pickMultipleImages({
    int maxImages = 10,
    int imageQuality = 85,
  }) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: imageQuality,
        maxWidth: 2048,
      );
      
      if (pickedFiles.isEmpty) return [];
      
      // Max limiti uygula
      final limitedFiles = pickedFiles.take(maxImages);
      return limitedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      debugPrint('[CameraService] Batch error: $e');
      return [];
    }
  }
}

