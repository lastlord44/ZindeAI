# ZindeAI — MANIFEST (Flutter-only • Photo-First • Simple MVP) — v1.8

**Sürüm:** v1.8 (2025-09-16)  
**Repo:** https://github.com/lastlord44/ZindeAI  
**Zaman Dilimi:** Europe/Istanbul  
**Platform:** Flutter (Android/iOS) • Google Cloud ($300 credit)

## 0) GLOBAL OPUS SİSTEM SÖZLEŞMESİ

**SEN:** Dünyanın en iyi Flutter mimarı, diyetisyeni, PT koçu ve LLM/Vision mühendisi.  
**AMAÇ:** En yüksek fayda/maliyet oranlı, ölçeklenebilir, bakımı kolay, performanslı ZindeAI.  
**YETKİ:** Mimari, algoritma, JSON şema, model seçimi (Tier-A/B), periodizasyon, hedef çatışması çözümü sende.  
**İLKE:** Bu manifest çerçeve; daha iyi bir yol görürsen kısa gerekçe ile onu uygula (vizyonu bozma).  
**ÇIKIŞ:** Production-ready; metin çıktıları JSON-STRICT; gereksiz laf yok.

### 0.A) OPUS MANIFEST OVERRIDE
Gerekirse yeni MANIFEST versiyonu üret, PR aç (docs/CHANGELOG.md + MANIFEST.md bump, ≤10 satır gerekçe).

### 0.B) DEĞİŞTİRİLEMEZ KORUMALAR
- Flutter-only, offline-first (plan iskeleti cihazda; AI: refine/explain/swap/vision)
- API key güvenliği: Mobilde ASLA tutma. n8n proxy (önerilen) VEYA Firebase Functions
- Gizlilik: Foto & veriler cihazda; base64 transfer sadece analiz için; 24 saat sonra n8n'den sil
- Bütçe ≤ $500/ay (kısa prompt + cache + Tier-B varsayılan)
- KVKK/GDPR: Açık onay, veri silme hakkı, minimal veri transferi

## 1) MVP ÜRÜN (Super Simple)

### 1.1) CORE (v1.8 - Gerçek MVP)
- **FoodSnap:** Foto + kullanıcı açıklaması → kcal/P/C/F tahmini
- **Timeline:** Günlük liste, toplam kalori
- **Basit Profil:** Boy, kilo, hedef kalori

### 1.2) SONRA EKLENİR (Roadmap)
- Barkod tarama
- Templates
- Water tracking  
- Haftalık özetler
- Vision modeller (test edilince)

## 2) TEKNİK YAKLAŞIM (Keep It Simple)

### 2.1) API Strategy
- **Başlangıç:** Direkt Groq API (API key Firebase Remote Config'de)
- **Text-Only:** Kullanıcı foto + "2 yumurta, tost" açıklaması
- **Model:** `gemma2-9b-it` (14,400 req/day - yeter de artar)
- **n8n:** İleride kurarsın (şimdilik gereksiz)

### 2.2) Storage
- **Google Firestore:** User profiles, meal logs (NoSQL, bedava tier)
- **Cloud Storage:** Fotolar (10GB free)
- **Local:** Sadece cache ve temp files

## 3) SIMPLE ARCHITECTURE

### 3.1) Klasör Yapısı (Minimal)
```
lib/
  models/
    meal.dart         // foto path + makrolar
    user.dart         // profil
  services/
    camera_service.dart
    groq_service.dart     // direkt API call
    storage_service.dart  // Firestore wrapper
  screens/
    home_screen.dart      // timeline
    camera_screen.dart    // foto çek
    profile_screen.dart   // settings
  main.dart
```

### 3.2) Dependencies (Sadece gerekli olanlar)
```yaml
dependencies:
  camera: ^latest
  image_picker: ^latest
  image: ^latest          # resize için
  http: ^latest           # Groq API
  firebase_core: ^latest
  cloud_firestore: ^latest
  firebase_storage: ^latest
  firebase_remote_config: ^latest  # API key için
```

```
lib/
  models/
    meal_photo.dart      ✅ AKTİF
    food_estimate.dart   ✅ AKTİF
    day_log.dart        ✅ AKTİF
    user_profile.dart   ✅ AKTİF (basit versiyon)
    
  services/
    camera_service.dart     ✅ AKTİF
    image_pipeline.dart     ✅ AKTİF
    dedupe_service.dart     ✅ AKTİF
    foodsnap_service.dart   ✅ AKTİF
    db_service.dart        ✅ AKTİF
    validators.dart        ✅ AKTİF (basit)
    
  ui/
    screens/
      capture.dart      ✅ AKTİF
      timeline.dart     ✅ AKTİF
      profile.dart      ✅ AKTİF (basit)
      settings.dart     ✅ AKTİF (minimal)
      
    widgets/
      photo_tile.dart   ✅ AKTİF
      macro_badge.dart  ✅ AKTİF
      
  core/
    constants.dart      ✅ AKTİF
    theme.dart         ✅ AKTİF
    env.dart           ✅ AKTİF (sadece temel config)
    permissions.dart   ✅ AKTİF
    
assets/images/         ✅ AKTİF
docs/
  README.md           ✅ AKTİF
  CHANGELOG.md        ✅ AKTİF
```

## 4) CORE FLOW (Basit ve Net)

### 4.1) User Journey
1. Foto çek → Resize (1280px) → Cloud Storage'a yükle
2. "Ne yedin?" → Kullanıcı: "Menemen, ekmek"
3. Groq API → JSON makro tahmini
4. Firestore'a kaydet
5. Timeline'da göster

### 4.2) Groq Integration (Direkt)
```dart
// Simple prompt
final prompt = '''
User ate: $userDescription
Estimate macros in JSON:
{"kcal": 0, "protein": 0, "carbs": 0, "fat": 0}
''';

// API call
final response = await http.post(
  'https://api.groq.com/openai/v1/chat/completions',
  headers: {'Authorization': 'Bearer $apiKey'},
  body: {
    'model': 'gemma2-9b-it',
    'messages': [{'role': 'user', 'content': prompt}],
    'response_format': {'type': 'json_object'}
  }
);
```

### 4.3) Error Handling (Basit)
- API fail → "Tekrar dene" butonu
- Network yok → "İnternet bağlantısı yok"
- Rate limit → "Günlük limit doldu" (kullanıcıya net bilgi)

## 5) DATABASE (Google Cloud - Bedava Tier)

### 5.1) Firestore Collections
```javascript
// users/{userId}
{
  height: 175,
  weight: 75,
  targetKcal: 2000,
  createdAt: timestamp
}

// meals/{mealId}
{
  userId: "xxx",
  photoUrl: "gs://...",
  description: "Menemen, ekmek",
  kcal: 350,
  protein: 15,
  carbs: 30,
  fat: 20,
  createdAt: timestamp
}
```

### 5.2) Cloud Storage
- `/photos/{userId}/{timestamp}.jpg` - original (1280px)
- `/thumbs/{userId}/{timestamp}.jpg` - thumbnail (256px)

### 5.3) Costs
- Firestore: 50K reads/day free
- Storage: 10GB free
- **Toplam: $0 (ilk 3 ay kesin yeter)**

## 6) MVP ROADMAP (2 Hafta Max)

### Week 1: Core
- Day 1-2: Flutter setup, Firebase bağlantısı
- Day 3-4: Camera + Groq integration
- Day 5-7: Firestore CRUD, basic UI

### Week 2: Polish
- Day 8-9: Error handling, loading states
- Day 10-11: Profile screen, settings
- Day 12-14: Test, bug fix, Play Store hazırlık

### Sonra (Para/kullanıcı gelince):
- n8n proxy kurulumu
- Vision model test
- Barkod, templates
- Premium features

## 7) COSTS & SCALING

### 7.1) İlk 3 Ay (0₺)
- Groq: Free tier (14,400 req/day)
- Google Cloud: $300 credit
- Toplam: **0₺**

### 7.2) 3-6 Ay (Minimal)
- Groq limitler dolunca: ~$20/ay
- Firebase Blaze plan: ~$25/ay
- Toplam: **~$45/ay**

### 7.3) Scale (1000+ users)
- Together AI veya dedicated Groq
- Cloud Functions for proxy
- Toplam: **~$200/ay**

## 8) SÜRÜM GEÇMİŞİ

| Versiyon | Tarih | Not |
|----------|-------|-----|
| v1.7.3 | 2025-09-16 | Over-engineered version (n8n, pHash, vs) |
| **v1.8** | **2025-09-16** | **REAL MVP: Simple, direct, Google Cloud, no bullshit** ✅ |

---

## NEDEN v1.8?

**v1.7.3 problemleri:**
- n8n proxy = gereksiz kompleksite başlangıçta
- pHash dedupe = overengineering 
- Vision models = test edilmemiş, belki çalışmıyor
- Offline mode = 100 meal DB kim yapacak?

**v1.8 avantajları:**
- 2 haftada markette
- Direkt Groq API (Firebase Remote Config'de key)
- Google Cloud $300 = 3 ay bedava
- Basit text-only (kullanıcı açıklama girer)
- Scale edince features eklersin

**Bottom line:** Start simple, iterate fast, scale smart! 🚀

### PHASE 1 - Core MVP (1-2 hafta)
1. **Bootstrap & n8n Setup**
   - Flutter scaffold
   - n8n proxy VPS'te kur (Groq API key burada)
   - Fallback: Firebase Functions (n8n yoksa)
   
2. **Smart FoodSnap Pipeline**
   - camera_service + image_pipeline
   - pHash implementation (image paketi + DCT)
   - Groq vision/text hybrid approach
   - Offline mode: precomputed Turkish meals DB
   
3. **v1.4 Light Features**
   - **Barkod:** OpenFoodFacts primary, Groq fallback
   - **Templates:** Local JSON storage, no API calls
   - **Water:** Simple counter, local notifications
   - **Light Weekly:** DB aggregates only (no LLM)

### PHASE 2 - Optimization (1 hafta)
- Rate limit management (Groq quota tracker)
- Offline mode (cached estimates)
- Template library (breakfast/lunch presets)

### PHASE 3 - Scale Prep (Para gelince)
- n8n proxy setup
- Multi-provider support (Together, Replicate)
- Premium features (haftalık rapor, cheat sistem)

## 9) n8n WORKFLOWS (VPS'de hazır!)

### 9.1) CORE WORKFLOWS
```yaml
FoodSnapProxy:
  - Input: base64_image, user_description, user_id
  - Cache check (Redis/SQLite)
  - Rate limit check (model seçimi)
  - Groq API call
  - Response cache
  - Return JSON

RateLimitManager:
  - Track: RPM, RPD, TPM, TPD per model
  - Auto-switch models when limits near
  - Reset counters at intervals

BarcodeLookup:
  - OpenFoodFacts API first
  - Cache results 30 days
  - Fallback to Groq text estimate

PurgeOldPayloads: # KVKK/GDPR uyumu
  - Schedule: Her 1 saatte
  - Delete: createdAt > RETENTION_HOURS (24h)
  - Log: Silinen kayıt sayısı, en eski timestamp
```

### 9.2) VPS RESOURCE PLANNING
- **n8n:** 512MB RAM yeterli
- **Cache DB:** SQLite (100MB) veya Redis
- **Logs:** 7 gün rotation
- **Backup:** Günlük cache export
- **Purge:** 24 saat sonra base64 payloadları sil

## 11) MONETİZASYON (0₺ Bootstrap Reality)

### MVP (İlk 6 ay - TAMAMEN BEDAVA)
- **Groq Free Tier:** 14,400 req/day (gemma/llama-8b)
- **n8n VPS:** Zaten var (1 yıllık)
- **Google Cloud:** $300 credit (3 ay database)
- **OpenFoodFacts:** Bedava, limitsiz
- **Toplam maliyet:** 0₺/ay

### BÜYÜME (6+ ay, 1000+ kullanıcı)
- Cache hit rate %70+ = Groq limitleri yeter
- İlk 1000 kullanıcı lifetime free
- Sonraki kullanıcılar: ₺39/ay (Spotify fiyatı)

### SCALE (10K+ kullanıcı)
- Together AI: $0.20/1M tokens
- Dedicated Groq tier: $100/ay
- Pro features unlock

## 11) SÜRÜM GEÇMİŞİ

| Versiyon | Tarih | Not |
|----------|-------|-----|
| v1.2 | 2025-09-16 | Opus-Supreme: manifest override yetkisi |
| v1.3 | 2025-09-16 | Konsolidasyon; Free/Pro netleşti |
| v1.4 | 2025-09-16 | Barkod, Templates, Water Tracking eklendi |
| **v1.5** | **2025-09-16** | **MVP Focus: Core features only** ✅ |
| **v1.5.1** | **2025-09-16** | **Groq free tier reality check** 🚀 |
| **v1.6** | **2025-09-16** | **v1.4 features Groq-optimized** 🎯 |
| **v1.7** | **2025-09-16** | **n8n VPS entegrasyonu + multi-model routing** 🔥 |
| **v1.7.1** | **2025-09-16** | **Reality check: OFF limits, Light özet** ✅ |
| **v1.7.2** | **2025-09-16** | **Koşullu Vision + Error handling + Privacy notları** 🎯 |
| **v1.7.3** | **2025-09-16** | **FINAL: pHash detay, offline mode, KVKK/GDPR** ✅ |

---

## NEDEN BU YAKLAŞIM?

**MVP = Maximum Value, Minimum Complexity**
- FoodSnap core value prop'u test etmeye odaklan
- Kullanıcı feedback'i al, sonra genişlet
- Technical debt minimize, iteration speed maximize
- Bütçe kontrolü: Direct API ile başla, scale edince n8n proxy

**Öncelik sırası:**
1. Foto → Makro tahmini (core loop)
2. Günlük takip & görselleştirme
3. Kullanıcı deneyimi refinement
4. Sonra: fancy features

---

*Not: Pasif özellikler silinmedi, roadmap'te bekliyor. MVP başarılı olunca sırayla aktive edilecek.*
