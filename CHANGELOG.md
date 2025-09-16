# Changelog

Tüm önemli değişiklikler bu dosyada belgelenmiştir.

## [Unreleased]

### Added
- Proje temel yapısı oluşturuldu
- Flutter projesi bootstrap edildi
- Temel klasör yapısı ve dosya iskeletleri oluşturuldu
- **Issue #1 Implementation (Manifest v1.8 Compliance):**
  - CameraService: Kamera ve galeri seçim servisi
  - ImagePipeline: EXIF fix, resize, thumbnail üretimi, average hash
  - DedupeService: Duplicate tespiti için Hamming distance ve hash kaydı
  - Comprehensive test suite with platform channel mocks
  - Implementation documentation and verification scripts

### Services Completed
- **CameraService**: Camera initialization, photo capture, gallery selection, permission handling
- **ImagePipeline**: EXIF orientation fix, image resizing, thumbnail generation, average hash calculation  
- **DedupeService**: Hamming distance calculation, duplicate detection, hash storage with JSON persistence

### Testing
- 45 comprehensive test cases across all services
- Platform channel mocks for Flutter integration
- Error handling and edge case validation
- Performance and data integrity verification

### Dependencies
- camera: ^0.10.5+9
- image_picker: ^1.0.7
- image: ^4.1.7
- http: ^1.2.1
- firebase_core: ^2.24.2
- cloud_firestore: ^4.13.6
- firebase_storage: ^11.6.0
- firebase_remote_config: ^4.3.8

## [1.0.0] - 2024-09-16

### Added
- İlk sürüm yayınlandı
- Temel proje yapısı oluşturuldu

### Architecture
- MVC yapısı benimsendi
- Service katmanı oluşturuldu
- Firebase entegrasyonu hazırlandı

### Services
- CameraService: Kamera ve resim işleme servisi
- GroqService: AI/LLM entegrasyon servisi  
- StorageService: Firebase veri saklama servisi

### Documentation
- README.md oluşturuldu
- CHANGELOG.md oluşturuldu
- DECISIONS.md oluşturuldu

---

Bu changelog formatı [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) standardını takip eder.