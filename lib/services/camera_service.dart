import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Service for handling camera operations and photo capture
class CameraService {
  static List<CameraDescription>? _cameras;
  static CameraController? _controller;

  /// Initialize available cameras
  static Future<void> initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
    }
  }

  /// Get available cameras
  static List<CameraDescription>? get cameras => _cameras;

  /// Initialize camera controller
  static Future<CameraController?> initializeController({
    CameraDescription? camera,
  }) async {
    if (_cameras == null || _cameras!.isEmpty) {
      return null;
    }

    final selectedCamera = camera ?? _cameras!.first;
    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      return _controller;
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
      return null;
    }
  }

  /// Take a picture and return the file path
  static Future<String?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      final image = await _controller!.takePicture();
      return image.path;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  /// Dispose camera controller
  static Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}