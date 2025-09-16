# DECISIONS

## Architecture Decisions

### 1. Flutter-only Approach
**Decision**: Sadece Flutter kullanılacak, hybrid yaklaşım yok.
**Reasoning**: MANIFEST v1.8'e göre minimum complexity için Flutter-only.
**Date**: 2024-09-16

### 2. Firebase Backend
**Decision**: Google Cloud/Firebase ekosistemi kullanılacak.
**Reasoning**: 
- $300 ücretsiz kredi
- Firestore bedava tier (50K reads/day)
- Cloud Storage 10GB ücretsiz
- Remote Config için API key güvenliği
**Date**: 2024-09-16

### 3. Groq API Integration
**Decision**: Başlangıçta direkt Groq API, n8n proxy opsiyonel.
**Reasoning**: 
- 14,400 request/day bedava tier
- gemma2-9b-it model yeterli
- n8n proxy karmaşıklığı başlangıçta gereksiz
**Date**: 2024-09-16

### 4. Text-First Approach
**Decision**: Başlangıçta kullanıcı fotoğraf + text açıklama.
**Reasoning**: 
- Vision model henüz test edilmemiş
- Text-only daha güvenilir sonuçlar
- Groq API limitlerini korur
**Date**: 2024-09-16

### 5. Minimal MVP Scope
**Decision**: Sadece core features: foto çek, makro tahmin, timeline.
**Reasoning**: 
- MANIFEST v1.8 "Real MVP" prensibi
- 2 hafta içinde market'e çıkabilir
- Feature creep önlenir
**Date**: 2024-09-16

## Technical Decisions

### 1. Folder Structure
```
lib/
  models/     # Data models
  services/   # Business logic & API calls
  screens/    # UI screens
```
**Reasoning**: Flutter clean architecture prensiplerine uygun, basit ve anlaşılır.

### 2. State Management
**Decision**: Provider pattern kullanılacak (sonradan karar verilecek).
**Reasoning**: Flutter ekibi tarafından önerilen, öğrenmesi kolay.

### 3. Local Storage
**Decision**: Sadece cache için, primary storage Firestore.
**Reasoning**: Offline-first yaklaşımı şimdilik karmaşık, cloud-first tercih.

## Security Decisions

### 1. API Key Management
**Decision**: Firebase Remote Config'de tutulacak.
**Reasoning**: 
- Mobil app'te hardcode etmek güvenlik riski
- Remote Config ücretsiz ve güvenli
- n8n proxy kurulana kadar geçici çözüm

### 2. Photo Privacy
**Decision**: Base64 transfer, 24 saat sonra n8n'den silinecek.
**Reasoning**: KVKV/GDPR uyumu, minimal data retention.

## Business Decisions

### 1. Free Tier Strategy
**Decision**: İlk 3 ay tamamen ücretsiz.
**Reasoning**: 
- Groq free tier + Google Cloud credits
- User acquisition için barrier yok
- MVV validate edildikten sonra monetization

### 2. Turkish Focus
**Decision**: Türk mutfağına özel optimization.
**Reasoning**: 
- Niche market advantage
- Local food database daha doğru sonuçlar
- Competition'da farklılaşma