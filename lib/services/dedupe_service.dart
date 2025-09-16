import 'dart:convert';
import 'dart:io';
import 'image_pipeline.dart';

/// Duplicate detection service using average hash and Hamming distance
/// Stores and compares image hashes to detect duplicate food photos
class DedupeService {
  static const int _defaultThreshold = 8; // Hamming distance threshold
  static const String _hashCacheFile = 'image_hashes.json';
  
  final Map<String, ImageHashRecord> _hashCache = {};
  final int _hammingThreshold;
  
  DedupeService({int hammingThreshold = _defaultThreshold}) 
      : _hammingThreshold = hammingThreshold;
  
  /// Initialize service and load existing hashes
  Future<void> initialize() async {
    await _loadHashCache();
  }
  
  /// Check if image is duplicate based on average hash
  Future<DuplicateCheckResult> checkDuplicate(String imageHash, {String? imagePath}) async {
    final List<DuplicateMatch> matches = [];
    
    for (final entry in _hashCache.entries) {
      final String existingHash = entry.value.hash;
      final int distance = calculateHammingDistance(imageHash, existingHash);
      
      if (distance <= _hammingThreshold) {
        matches.add(DuplicateMatch(
          hashId: entry.key,
          hash: existingHash,
          hammingDistance: distance,
          imagePath: entry.value.imagePath,
          timestamp: entry.value.timestamp,
          similarity: _calculateSimilarity(distance),
        ));
      }
    }
    
    // Sort by similarity (lowest hamming distance first)
    matches.sort((a, b) => a.hammingDistance.compareTo(b.hammingDistance));
    
    final bool isDuplicate = matches.isNotEmpty;
    final DuplicateMatch? bestMatch = matches.isNotEmpty ? matches.first : null;
    
    return DuplicateCheckResult(
      isDuplicate: isDuplicate,
      bestMatch: bestMatch,
      allMatches: matches,
      checkedHash: imageHash,
      hammingThreshold: _hammingThreshold,
    );
  }
  
  /// Store image hash for future duplicate detection
  Future<String> storeHash(String imageHash, {String? imagePath}) async {
    final String hashId = _generateHashId();
    final ImageHashRecord record = ImageHashRecord(
      id: hashId,
      hash: imageHash,
      imagePath: imagePath,
      timestamp: DateTime.now(),
    );
    
    _hashCache[hashId] = record;
    await _saveHashCache();
    
    return hashId;
  }
  
  /// Remove hash from storage
  Future<bool> removeHash(String hashId) async {
    final bool removed = _hashCache.remove(hashId) != null;
    if (removed) {
      await _saveHashCache();
    }
    return removed;
  }
  
  /// Calculate Hamming distance between two binary hash strings
  int calculateHammingDistance(String hash1, String hash2) {
    if (hash1.length != hash2.length) {
      throw ArgumentError('Hash strings must have the same length');
    }
    
    int distance = 0;
    for (int i = 0; i < hash1.length; i++) {
      if (hash1[i] != hash2[i]) {
        distance++;
      }
    }
    
    return distance;
  }
  
  /// Calculate similarity percentage from Hamming distance
  double _calculateSimilarity(int hammingDistance) {
    const int maxDistance = 64; // For 64-bit hash
    return ((maxDistance - hammingDistance) / maxDistance) * 100;
  }
  
  /// Get all stored hashes
  List<ImageHashRecord> getAllHashes() {
    return _hashCache.values.toList();
  }
  
  /// Get hash record by ID
  ImageHashRecord? getHashRecord(String hashId) {
    return _hashCache[hashId];
  }
  
  /// Clear all stored hashes
  Future<void> clearAllHashes() async {
    _hashCache.clear();
    await _saveHashCache();
  }
  
  /// Get statistics about stored hashes
  DedupeStatistics getStatistics() {
    final List<ImageHashRecord> hashes = getAllHashes();
    
    if (hashes.isEmpty) {
      return DedupeStatistics(
        totalHashes: 0,
        oldestHash: null,
        newestHash: null,
        averageAge: Duration.zero,
      );
    }
    
    hashes.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    final DateTime now = DateTime.now();
    final Duration totalAge = hashes.fold<Duration>(
      Duration.zero,
      (sum, hash) => sum + now.difference(hash.timestamp),
    );
    
    return DedupeStatistics(
      totalHashes: hashes.length,
      oldestHash: hashes.first.timestamp,
      newestHash: hashes.last.timestamp,
      averageAge: Duration(
        milliseconds: totalAge.inMilliseconds ~/ hashes.length,
      ),
    );
  }
  
  /// Cleanup old hashes (older than specified duration)
  Future<int> cleanupOldHashes(Duration maxAge) async {
    final DateTime cutoff = DateTime.now().subtract(maxAge);
    final List<String> toRemove = [];
    
    for (final entry in _hashCache.entries) {
      if (entry.value.timestamp.isBefore(cutoff)) {
        toRemove.add(entry.key);
      }
    }
    
    for (final hashId in toRemove) {
      _hashCache.remove(hashId);
    }
    
    if (toRemove.isNotEmpty) {
      await _saveHashCache();
    }
    
    return toRemove.length;
  }
  
  /// Generate unique hash ID
  String _generateHashId() {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final int random = (timestamp * 31) % 1000000;
    return 'hash_${timestamp}_$random';
  }
  
  /// Load hash cache from storage
  Future<void> _loadHashCache() async {
    try {
      final String cacheDir = await _getCacheDirectory();
      final File cacheFile = File('$cacheDir/$_hashCacheFile');
      
      if (await cacheFile.exists()) {
        final String content = await cacheFile.readAsString();
        final Map<String, dynamic> jsonData = jsonDecode(content);
        
        for (final entry in jsonData.entries) {
          final Map<String, dynamic> recordData = entry.value;
          final ImageHashRecord record = ImageHashRecord.fromJson(recordData);
          _hashCache[entry.key] = record;
        }
      }
    } catch (e) {
      // If loading fails, start with empty cache
      _hashCache.clear();
    }
  }
  
  /// Save hash cache to storage
  Future<void> _saveHashCache() async {
    try {
      final String cacheDir = await _getCacheDirectory();
      final Directory dir = Directory(cacheDir);
      
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      final File cacheFile = File('$cacheDir/$_hashCacheFile');
      final Map<String, dynamic> jsonData = {};
      
      for (final entry in _hashCache.entries) {
        jsonData[entry.key] = entry.value.toJson();
      }
      
      await cacheFile.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      throw DedupeException('CACHE_SAVE_FAILED', 'Failed to save hash cache: $e');
    }
  }
  
  /// Get cache directory path
  Future<String> _getCacheDirectory() async {
    // For testing, use /tmp directory
    // In production, this would use the app's cache directory
    return '/tmp/zindeai_cache';
  }
}

/// Image hash record for storage
class ImageHashRecord {
  final String id;
  final String hash;
  final String? imagePath;
  final DateTime timestamp;
  
  const ImageHashRecord({
    required this.id,
    required this.hash,
    this.imagePath,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hash': hash,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory ImageHashRecord.fromJson(Map<String, dynamic> json) {
    return ImageHashRecord(
      id: json['id'],
      hash: json['hash'],
      imagePath: json['imagePath'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
  
  @override
  String toString() {
    return 'ImageHashRecord(id: $id, hash: $hash, timestamp: $timestamp)';
  }
}

/// Duplicate match result
class DuplicateMatch {
  final String hashId;
  final String hash;
  final int hammingDistance;
  final String? imagePath;
  final DateTime timestamp;
  final double similarity;
  
  const DuplicateMatch({
    required this.hashId,
    required this.hash,
    required this.hammingDistance,
    this.imagePath,
    required this.timestamp,
    required this.similarity,
  });
  
  @override
  String toString() {
    return 'DuplicateMatch('
        'id: $hashId, '
        'distance: $hammingDistance, '
        'similarity: ${similarity.toStringAsFixed(1)}%'
        ')';
  }
}

/// Result of duplicate check operation
class DuplicateCheckResult {
  final bool isDuplicate;
  final DuplicateMatch? bestMatch;
  final List<DuplicateMatch> allMatches;
  final String checkedHash;
  final int hammingThreshold;
  
  const DuplicateCheckResult({
    required this.isDuplicate,
    this.bestMatch,
    required this.allMatches,
    required this.checkedHash,
    required this.hammingThreshold,
  });
  
  @override
  String toString() {
    return 'DuplicateCheckResult('
        'isDuplicate: $isDuplicate, '
        'matches: ${allMatches.length}, '
        'bestSimilarity: ${bestMatch?.similarity.toStringAsFixed(1)}%'
        ')';
  }
}

/// Statistics about stored hashes
class DedupeStatistics {
  final int totalHashes;
  final DateTime? oldestHash;
  final DateTime? newestHash;
  final Duration averageAge;
  
  const DedupeStatistics({
    required this.totalHashes,
    this.oldestHash,
    this.newestHash,
    required this.averageAge,
  });
  
  @override
  String toString() {
    return 'DedupeStatistics('
        'total: $totalHashes, '
        'oldest: $oldestHash, '
        'newest: $newestHash, '
        'avgAge: ${averageAge.inDays} days'
        ')';
  }
}

/// Custom exception for dedupe operations
class DedupeException implements Exception {
  final String code;
  final String message;
  
  const DedupeException(this.code, this.message);
  
  @override
  String toString() => 'DedupeException($code): $message';
}