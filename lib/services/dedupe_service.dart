import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DedupeService {
  static const String _hashStorageKey = 'image_hashes';
  static const int _hammingThreshold = 12;
  static const int _maxStoredHashes = 1000;

  /// Hash karşılaştırması ve duplicate kontrolü - DÜZELTİLMİŞ
  static Future<Map<String, dynamic>> checkDuplicate(String newHash) async {
    final stopwatch = Stopwatch()..start();

    try {
      final existingHashes = await _loadStoredHashes();

      // Benzerlik kontrolü
      String? matchedHash;
      int minDistance = 999;

      for (final stored in existingHashes) {
        final distance = _hammingDistance(newHash, stored['hash']);
        if (distance < minDistance) {
          minDistance = distance;
          if (distance < _hammingThreshold) {
            matchedHash = stored['hash'];
            // Eğer tam eşleşme ise (distance = 0) hemen dur
            if (distance == 0) break;
          }
        }
      }

      final isDuplicate = matchedHash != null;

      // Yeni hash'i sadece duplicate değilse kaydet
      if (!isDuplicate) {
        await _storeHash(newHash);
      }

      stopwatch.stop();

      return {
        'isDuplicate': isDuplicate,
        'matchedHash': matchedHash,
        'distance': minDistance,
        'threshold': _hammingThreshold,
        'processingTime': stopwatch.elapsedMilliseconds,
      };
    } catch (e) {
      return {
        'isDuplicate': false,
        'error': e.toString(),
        'processingTime': stopwatch.elapsedMilliseconds,
      };
    }
  }

  /// Hamming mesafesi hesaplama
  static int _hammingDistance(String hash1, String hash2) {
    if (hash1.length != hash2.length) return 999;

    int distance = 0;

    // Hex'ten binary'e çevir ve karşılaştır
    for (int i = 0; i < hash1.length; i++) {
      final val1 = int.parse(hash1[i], radix: 16);
      final val2 = int.parse(hash2[i], radix: 16);

      // XOR ve bit sayma
      int xor = val1 ^ val2;
      while (xor != 0) {
        xor &= xor - 1;
        distance++;
      }
    }

    return distance;
  }

  /// Kayıtlı hash'leri yükle
  static Future<List<Map<String, dynamic>>> _loadStoredHashes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_hashStorageKey);

    if (jsonString == null) return [];

    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Yeni hash kaydet - DÜZELTİLMİŞ
  static Future<void> _storeHash(String hash) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await _loadStoredHashes();

    // Duplicate kontrolü - aynı hash varsa ekleme
    if (existing.any((item) => item['hash'] == hash)) {
      return;
    }

    // Yeni hash'i ekle
    existing.insert(0, {
      'hash': hash,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Max limit kontrolü (FIFO)
    if (existing.length > _maxStoredHashes) {
      existing.removeRange(_maxStoredHashes, existing.length);
    }

    // Kaydet
    await prefs.setString(_hashStorageKey, json.encode(existing));
  }

  /// Hash veritabanını temizle
  static Future<void> clearHashDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hashStorageKey);
  }

  /// İstatistikleri getir
  static Future<Map<String, dynamic>> getStats() async {
    final hashes = await _loadStoredHashes();
    return {
      'totalHashes': hashes.length,
      'maxCapacity': _maxStoredHashes,
      'oldestHash': hashes.isNotEmpty ? hashes.last['timestamp'] : null,
      'newestHash': hashes.isNotEmpty ? hashes.first['timestamp'] : null,
    };
  }
}
