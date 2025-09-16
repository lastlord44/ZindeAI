# ZindeAI

Türk mutfağına özel akıllı beslenme planlama sistemi. LLM + algoritma, Groq entegrasyonu ve otomasyon ile geliştirilmiş Flutter uygulaması.

## Özellikler

- 📸 **FoodSnap**: Yemek fotoğrafı çekerek otomatik kalori ve makro besin analizi
- 📊 **Günlük Takip**: Kalori ve makro besin değerlerinin takibi
- 👤 **Kişisel Profil**: Boy, kilo ve hedef kalori bilgileri
- 🤖 **AI Destekli**: Groq LLM entegrasyonu ile akıllı besin analizi

## Teknoloji Yığını

- **Frontend**: Flutter (Android/iOS)
- **Backend**: Firebase (Firestore, Storage, Remote Config)
- **AI**: Groq API (gemma2-9b-it model)
- **Dil**: Dart 3.0+

## Kurulum

1. Flutter SDK'yı kurun (3.0.0+)
2. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```
3. Firebase projesini yapılandırın
4. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

## Proje Yapısı

```
lib/
├── models/          # Veri modelleri
├── services/        # API ve servis katmanları
├── screens/         # UI ekranları
└── main.dart        # Ana uygulama dosyası
```

## Bağımlılıklar

- **camera**: Kamera ve fotoğraf çekimi
- **image_picker**: Galeriden resim seçimi
- **image**: Resim işleme ve boyutlandırma
- **http**: API iletişimi
- **firebase_core**: Firebase temel konfigürasyon
- **cloud_firestore**: NoSQL veritabanı
- **firebase_storage**: Dosya depolama
- **firebase_remote_config**: Uzaktan yapılandırma

## Dokümantasyon

- [CHANGELOG.md](CHANGELOG.md) - Versiyon geçmişi
- [DECISIONS.md](DECISIONS.md) - Mimari kararlar

## Katkıda Bulunma

Bu proje açık kaynak olarak geliştirilmektedir. Katkıda bulunmak için:

1. Fork yapın
2. Feature branch oluşturun
3. Değişikliklerinizi commit edin
4. Pull request açın

## Lisans

Bu proje MIT lisansı altında yayınlanmıştır.
