import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'services/camera_service_test.dart' as camera_test;
import 'services/image_pipeline_test.dart' as image_test;
import 'services/dedupe_service_test.dart' as dedupe_test;

void main() {
  group('ZindeAI Service Tests', () {
    group('CameraService', camera_test.main);
    group('ImagePipeline', image_test.main);
    group('DedupeService', dedupe_test.main);
  });
}