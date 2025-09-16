import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

/// Camera service for capturing and processing food images
/// Handles camera initialization, photo capture, and gallery selection
class CameraService {
  static const MethodChannel _channel = MethodChannel('zindeai/camera');
  
  final ImagePicker _picker = ImagePicker();
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  
  /// Initialize camera service
  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
      }
    } catch (e) {
      throw CameraException('INITIALIZATION_FAILED', 'Failed to initialize camera: $e');
    }
  }
  
  /// Capture photo from camera
  Future<File?> capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw CameraException('CAMERA_NOT_INITIALIZED', 'Camera not initialized');
    }
    
    try {
      final XFile image = await _controller!.takePicture();
      return File(image.path);
    } catch (e) {
      throw CameraException('CAPTURE_FAILED', 'Failed to capture photo: $e');
    }
  }
  
  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      throw CameraException('GALLERY_PICK_FAILED', 'Failed to pick from gallery: $e');
    }
  }
  
  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      throw CameraException('GALLERY_PICK_MULTIPLE_FAILED', 'Failed to pick multiple from gallery: $e');
    }
  }
  
  /// Check camera permission
  Future<bool> checkCameraPermission() async {
    try {
      final bool hasPermission = await _channel.invokeMethod('checkCameraPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      throw CameraException('PERMISSION_CHECK_FAILED', 'Permission check failed: ${e.message}');
    }
  }
  
  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    try {
      final bool granted = await _channel.invokeMethod('requestCameraPermission');
      return granted;
    } on PlatformException catch (e) {
      throw CameraException('PERMISSION_REQUEST_FAILED', 'Permission request failed: ${e.message}');
    }
  }
  
  /// Check gallery permission
  Future<bool> checkGalleryPermission() async {
    try {
      final bool hasPermission = await _channel.invokeMethod('checkGalleryPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      throw CameraException('PERMISSION_CHECK_FAILED', 'Permission check failed: ${e.message}');
    }
  }
  
  /// Request gallery permission
  Future<bool> requestGalleryPermission() async {
    try {
      final bool granted = await _channel.invokeMethod('requestGalleryPermission');
      return granted;
    } on PlatformException catch (e) {
      throw CameraException('PERMISSION_REQUEST_FAILED', 'Permission request failed: ${e.message}');
    }
  }
  
  /// Get camera controller for custom use
  CameraController? get controller => _controller;
  
  /// Get available cameras
  List<CameraDescription>? get cameras => _cameras;
  
  /// Dispose camera controller
  void dispose() {
    _controller?.dispose();
  }
}

/// Custom exception for camera operations
class CameraException implements Exception {
  final String code;
  final String message;
  
  const CameraException(this.code, this.message);
  
  @override
  String toString() => 'CameraException($code): $message';
}