// camera_service.dart - Kamera işlemleri için servis
// TODO: Kamera çekme, görüntü işleme ve base64 dönüşümü

class CameraService {
  // Stub implementation
  // Bu dosya kamera işlemlerini yönetecek
  
  /// Kameradan fotoğraf çek
  Future<String?> capturePhoto() async {
    // TODO: Implement camera capture
    throw UnimplementedError('Camera capture not implemented yet');
  }
  
  /// Görüntüyü resize et (1280px max)
  Future<String> resizeImage(String imagePath) async {
    // TODO: Implement image resizing
    throw UnimplementedError('Image resizing not implemented yet');
  }
  
  /// Base64'e dönüştür
  String imageToBase64(String imagePath) {
    // TODO: Implement base64 conversion
    throw UnimplementedError('Base64 conversion not implemented yet');
  }
}