import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../../lib/services/camera_service.dart';

void main() {
  group('CameraService Tests', () {
    late CameraService cameraService;
    
    setUp(() {
      cameraService = CameraService();
      
      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('zindeai/camera'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'checkCameraPermission':
              return true;
            case 'requestCameraPermission':
              return true;
            case 'checkGalleryPermission':
              return true;
            case 'requestGalleryPermission':
              return true;
            default:
              return null;
          }
        },
      );
      
      // Mock camera plugin
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/camera'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'availableCameras':
              return [
                {
                  'name': 'camera0',
                  'lensFacing': 'back',
                  'sensorOrientation': 90,
                }
              ];
            case 'create':
              return {
                'cameraId': 0,
                'imageFormatGroup': 'jpeg',
                'captureSessionId': 0,
              };
            case 'initialize':
              return {
                'previewWidth': 1920.0,
                'previewHeight': 1080.0,
                'exposureMode': 'auto',
                'exposurePointSupported': true,
                'focusMode': 'auto',
                'focusPointSupported': true,
              };
            case 'takePicture':
              return '/tmp/test_image.jpg';
            case 'dispose':
              return null;
            default:
              return null;
          }
        },
      );
      
      // Mock image_picker plugin
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/image_picker'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'pickImage':
              return '/tmp/test_gallery_image.jpg';
            case 'pickMultiImage':
              return ['/tmp/test_image1.jpg', '/tmp/test_image2.jpg'];
            default:
              return null;
          }
        },
      );
    });
    
    tearDown(() {
      cameraService.dispose();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('zindeai/camera'), null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/camera'), null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/image_picker'), null);
    });
    
    test('should initialize camera successfully', () async {
      await cameraService.initialize();
      expect(cameraService.controller, isNotNull);
      expect(cameraService.cameras, isNotNull);
      expect(cameraService.cameras!.length, equals(1));
    });
    
    test('should handle initialization failure gracefully', () async {
      // Override mock to simulate failure
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/camera'),
        (MethodCall methodCall) async {
          throw PlatformException(code: 'camera_error', message: 'Camera not available');
        },
      );
      
      expect(
        () => cameraService.initialize(),
        throwsA(isA<CameraException>()),
      );
    });
    
    test('should capture photo successfully', () async {
      await cameraService.initialize();
      
      // Create a test file for the mock
      final testFile = File('/tmp/test_image.jpg');
      await testFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]); // JPEG header
      
      final File? capturedImage = await cameraService.capturePhoto();
      
      expect(capturedImage, isNotNull);
      expect(capturedImage!.path, equals('/tmp/test_image.jpg'));
      
      // Cleanup
      if (await testFile.exists()) {
        await testFile.delete();
      }
    });
    
    test('should throw exception when capturing without initialization', () async {
      expect(
        () => cameraService.capturePhoto(),
        throwsA(isA<CameraException>()),
      );
    });
    
    test('should pick image from gallery successfully', () async {
      // Create a test file for the mock
      final testFile = File('/tmp/test_gallery_image.jpg');
      await testFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]); // JPEG header
      
      final File? pickedImage = await cameraService.pickFromGallery();
      
      expect(pickedImage, isNotNull);
      expect(pickedImage!.path, equals('/tmp/test_gallery_image.jpg'));
      
      // Cleanup
      if (await testFile.exists()) {
        await testFile.delete();
      }
    });
    
    test('should pick multiple images from gallery successfully', () async {
      // Create test files for the mock
      final testFile1 = File('/tmp/test_image1.jpg');
      final testFile2 = File('/tmp/test_image2.jpg');
      await testFile1.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
      await testFile2.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
      
      final List<File> pickedImages = await cameraService.pickMultipleFromGallery();
      
      expect(pickedImages.length, equals(2));
      expect(pickedImages[0].path, equals('/tmp/test_image1.jpg'));
      expect(pickedImages[1].path, equals('/tmp/test_image2.jpg'));
      
      // Cleanup
      for (final file in [testFile1, testFile2]) {
        if (await file.exists()) {
          await file.delete();
        }
      }
    });
    
    test('should check camera permission successfully', () async {
      final bool hasPermission = await cameraService.checkCameraPermission();
      expect(hasPermission, isTrue);
    });
    
    test('should request camera permission successfully', () async {
      final bool granted = await cameraService.requestCameraPermission();
      expect(granted, isTrue);
    });
    
    test('should check gallery permission successfully', () async {
      final bool hasPermission = await cameraService.checkGalleryPermission();
      expect(hasPermission, isTrue);
    });
    
    test('should request gallery permission successfully', () async {
      final bool granted = await cameraService.requestGalleryPermission();
      expect(granted, isTrue);
    });
    
    test('should handle permission check failures', () async {
      // Override mock to simulate failure
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('zindeai/camera'),
        (MethodCall methodCall) async {
          throw PlatformException(code: 'permission_error', message: 'Permission denied');
        },
      );
      
      expect(
        () => cameraService.checkCameraPermission(),
        throwsA(isA<CameraException>()),
      );
    });
    
    test('CameraException should have proper string representation', () {
      const exception = CameraException('TEST_CODE', 'Test message');
      expect(exception.toString(), equals('CameraException(TEST_CODE): Test message'));
    });
  });
}