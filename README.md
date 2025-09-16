# ZindeAI

Türk mutfağına özel akıllı beslenme planlama sistemi. LLM + algoritma, Groq entegrasyonu ve n8n otomasyon.

## 🎯 Proje Durumu

**Mevcut Sürüm**: v1.0.0 (Bootstrap)  
**Platform**: Flutter (Android/iOS)  
**Backend**: Google Cloud/Firebase  
**AI Provider**: Groq API  

## 📱 Özellikler (MVP)

- **FoodSnap**: Fotoğraf + kullanıcı açıklaması → kalori/makro tahmini
- **Timeline**: Günlük yemek listesi ve toplam kalori
- **Profil**: Boy, kilo, hedef kalori ayarları

## 🏗️ Proje Yapısı

```
lib/
├── models/              # Data modelleri
│   ├── meal.dart       # Yemek modeli
│   └── user.dart       # Kullanıcı profil modeli
├── services/           # İş mantığı ve API çağrıları
│   ├── camera_service.dart    # Kamera işlemleri
│   ├── groq_service.dart      # Groq API entegrasyonu
│   └── storage_service.dart   # Firebase Firestore/Storage
├── screens/            # UI ekranları
│   ├── home_screen.dart       # Timeline ekranı
│   ├── camera_screen.dart     # Fotoğraf çekme
│   └── profile_screen.dart    # Profil ayarları
└── main.dart          # Entry point
```

## 🚀 Kurulum

```bash
# Projeyi klonla
git clone https://github.com/lastlord44/ZindeAI.git
cd ZindeAI

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

## ⚙️ Konfigürasyon

- **Firebase**: Opus tarafından yapılandırılacak
- **Groq API**: Remote Config'den yönetilecek
- **Environment**: Development/Production ortamları

## 📋 TODO

- [ ] Firebase konfigürasyonu
- [ ] Groq API entegrasyonu  
- [ ] Kamera işlevselliği
- [ ] UI/UX tasarımı
- [ ] Firestore veritabanı şeması
- [ ] Error handling
- [ ] Testing infrastructure

## 📚 Dokümantasyon

- [CHANGELOG.md](./CHANGELOG.md) - Sürüm geçmişi
- [DECISIONS.md](./DECISIONS.md) - Mimari kararlar
- [ZindeAI/docs/MANIFEST.md](./ZindeAI/docs/MANIFEST.md) - Teknik manifest

## 🤝 Katkıda Bulunma

Bu proje şu anda bootstrap aşamasında. Firebase konfigürasyonu Opus tarafından yönetilecek.

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.
