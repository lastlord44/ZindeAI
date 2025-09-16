# Architecture Decision Records (ADR)

Bu dosya ZindeAI projesi için alınan önemli mimari kararları belgelemektedir.

## ADR-001: Flutter Framework Seçimi

**Durum**: Kabul edildi  
**Tarih**: 2024-09-16

### Bağlam
Mobil uygulama geliştirme için framework seçimi yapılması gerekiyordu.

### Karar
Flutter framework'ü seçildi.

### Gerekçe
- Cross-platform geliştirme (Android/iOS)
- Tek kod tabanı ile iki platform
- Google desteği ve aktif topluluk
- Firebase entegrasyonu kolay
- Performans optimizasyonları mevcut

### Sonuçlar
- Geliştirme süreci hızlandı
- Bakım maliyeti azaldı
- Platform-specific özellikler plugin'ler ile erişilebilir

---

## ADR-002: Firebase Backend Seçimi

**Durum**: Kabul edildi  
**Tarih**: 2024-09-16

### Bağlam
Backend altyapısı için çözüm seçimi yapılması gerekiyordu.

### Karar
Google Firebase platformu seçildi.

### Gerekçe
- Firestore NoSQL veritabanı hızlı sorgular
- Firebase Storage resim depolama
- Remote Config için dinamik yapılandırma
- Otomatik ölçeklendirme
- Bedava tier yeterli başlangıç için

### Sonuçlar
- Hızlı MVP geliştirme
- Düşük başlangıç maliyeti
- Google Cloud ekosistemi entegrasyonu

---

## ADR-003: Groq API LLM Entegrasyonu

**Durum**: Kabul edildi  
**Tarih**: 2024-09-16

### Bağlam
Yemek analizi için AI/LLM entegrasyonu gerekiyordu.

### Karar
Groq API (gemma2-9b-it model) seçildi.

### Gerekçe
- Hızlı inference süresi
- 14,400 req/day bedava limit
- JSON output desteği
- Cost-effective çözüm
- Türkçe dil desteği

### Sonuçlar
- Hızlı makro besin analizi
- Düşük API maliyeti
- Gerçek zamanlı yanıtlar

---

## ADR-004: MVC Architecture Pattern

**Durum**: Kabul edildi  
**Tarih**: 2024-09-16

### Bağlam
Kod organizasyonu ve mimarisi için pattern seçimi.

### Karar
Model-View-Controller (MVC) pattern'i benimsenди.

### Gerekçe
- Separation of concerns
- Test edilebilir kod yapısı
- Bakım kolaylığı
- Flutter best practices uyumlu
- Takım gelişimi için uygun

### Sonuçlar
- Temiz kod yapısı
- Kolay test yazımı
- Modüler geliştirme imkanı

---

## ADR-005: Service Layer Pattern

**Durum**: Kabul edildi  
**Tarih**: 2024-09-16

### Bağlam
External API'ler ve veri erişimi için abstraction katmanı.

### Karar
Service layer pattern'i uygulandı.

### Gerekçe
- API'ler arası tutarlılık
- Error handling centralization
- Dependency injection kolaylığı
- Mock'lama imkanı testler için

### Sonuçlar
- Maintainable kod yapısı
- API değişikliklerinde esneklik
- Comprehensive test coverage

---

Bu ADR'lar proje gelişimi süresince güncellenecek ve yeni kararlar eklenecektir.