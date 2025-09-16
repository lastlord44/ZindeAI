import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import '../../lib/services/dedupe_service.dart';

void main() {
  group('DedupeService Tests', () {
    late DedupeService dedupeService;
    late Directory testCacheDir;
    
    setUp(() async {
      dedupeService = DedupeService();
      
      // Create test cache directory
      testCacheDir = Directory('/tmp/zindeai_cache_test');
      if (await testCacheDir.exists()) {
        await testCacheDir.delete(recursive: true);
      }
      await testCacheDir.create(recursive: true);
      
      await dedupeService.initialize();
    });
    
    tearDown(() async {
      if (await testCacheDir.exists()) {
        await testCacheDir.delete(recursive: true);
      }
    });
    
    test('should initialize successfully', () async {
      expect(dedupeService.getAllHashes().length, equals(0));
    });
    
    test('should store hash successfully', () async {
      const String testHash = '1010101100110011010101011001100110101010110011001101010101100110';
      
      final String hashId = await dedupeService.storeHash(testHash, imagePath: '/test/image.jpg');
      
      expect(hashId, isNotNull);
      expect(hashId, startsWith('hash_'));
      
      final List<ImageHashRecord> allHashes = dedupeService.getAllHashes();
      expect(allHashes.length, equals(1));
      expect(allHashes.first.hash, equals(testHash));
      expect(allHashes.first.imagePath, equals('/test/image.jpg'));
    });
    
    test('should detect duplicate with exact match', () async {
      const String testHash = '1010101100110011010101011001100110101010110011001101010101100110';
      
      // Store original hash
      await dedupeService.storeHash(testHash, imagePath: '/test/image1.jpg');
      
      // Check for duplicate
      final DuplicateCheckResult result = await dedupeService.checkDuplicate(testHash);
      
      expect(result.isDuplicate, isTrue);
      expect(result.bestMatch, isNotNull);
      expect(result.bestMatch!.hammingDistance, equals(0));
      expect(result.bestMatch!.similarity, equals(100.0));
      expect(result.allMatches.length, equals(1));
    });
    
    test('should detect near duplicate with small hamming distance', () async {
      const String originalHash = '1010101100110011010101011001100110101010110011001101010101100110';
      const String similarHash = '1010101100110011010101011001100110101010110011001101010101100111'; // 1 bit different
      
      // Store original hash
      await dedupeService.storeHash(originalHash, imagePath: '/test/image1.jpg');
      
      // Check for duplicate with similar hash
      final DuplicateCheckResult result = await dedupeService.checkDuplicate(similarHash);
      
      expect(result.isDuplicate, isTrue);
      expect(result.bestMatch, isNotNull);
      expect(result.bestMatch!.hammingDistance, equals(1));
      expect(result.bestMatch!.similarity, closeTo(98.4, 0.1)); // (64-1)/64 * 100
    });
    
    test('should not detect duplicate with large hamming distance', () async {
      const String originalHash = '1010101100110011010101011001100110101010110011001101010101100110';
      const String differentHash = '0101010011001100101010100110011001010101001100110010101010011001'; // Many bits different
      
      // Store original hash
      await dedupeService.storeHash(originalHash, imagePath: '/test/image1.jpg');
      
      // Check for duplicate with very different hash
      final DuplicateCheckResult result = await dedupeService.checkDuplicate(differentHash);
      
      expect(result.isDuplicate, isFalse);
      expect(result.bestMatch, isNull);
      expect(result.allMatches.length, equals(0));
    });
    
    test('should calculate hamming distance correctly', () {
      const String hash1 = '1010101100110011010101011001100110101010110011001101010101100110';
      const String hash2 = '1010101100110011010101011001100110101010110011001101010101100111'; // 1 bit different
      const String hash3 = '0000000000000000000000000000000000000000000000000000000000000000'; // All different
      
      expect(dedupeService.calculateHammingDistance(hash1, hash1), equals(0));
      expect(dedupeService.calculateHammingDistance(hash1, hash2), equals(1));
      expect(dedupeService.calculateHammingDistance(hash1, hash3), equals(32)); // Half the bits are 1
    });
    
    test('should throw error for mismatched hash lengths', () {
      const String hash1 = '10101011';
      const String hash2 = '101010110011'; // Different length
      
      expect(
        () => dedupeService.calculateHammingDistance(hash1, hash2),
        throwsA(isA<ArgumentError>()),
      );
    });
    
    test('should remove hash successfully', () async {
      const String testHash = '1010101100110011010101011001100110101010110011001101010101100110';
      
      // Store hash
      final String hashId = await dedupeService.storeHash(testHash);
      expect(dedupeService.getAllHashes().length, equals(1));
      
      // Remove hash
      final bool removed = await dedupeService.removeHash(hashId);
      expect(removed, isTrue);
      expect(dedupeService.getAllHashes().length, equals(0));
    });
    
    test('should return false when removing non-existent hash', () async {
      const String nonExistentId = 'non_existent_hash_id';
      
      final bool removed = await dedupeService.removeHash(nonExistentId);
      expect(removed, isFalse);
    });
    
    test('should get hash record by ID', () async {
      const String testHash = '1010101100110011010101011001100110101010110011001101010101100110';
      const String imagePath = '/test/image.jpg';
      
      final String hashId = await dedupeService.storeHash(testHash, imagePath: imagePath);
      
      final ImageHashRecord? record = dedupeService.getHashRecord(hashId);
      expect(record, isNotNull);
      expect(record!.hash, equals(testHash));
      expect(record.imagePath, equals(imagePath));
      expect(record.id, equals(hashId));
    });
    
    test('should return null for non-existent hash ID', () {
      final ImageHashRecord? record = dedupeService.getHashRecord('non_existent_id');
      expect(record, isNull);
    });
    
    test('should clear all hashes', () async {
      // Store multiple hashes
      await dedupeService.storeHash('1010101100110011010101011001100110101010110011001101010101100110');
      await dedupeService.storeHash('0101010011001100101010100110011001010101001100110010101010011001');
      
      expect(dedupeService.getAllHashes().length, equals(2));
      
      await dedupeService.clearAllHashes();
      expect(dedupeService.getAllHashes().length, equals(0));
    });
    
    test('should get correct statistics', () async {
      // Initially empty
      DedupeStatistics stats = dedupeService.getStatistics();
      expect(stats.totalHashes, equals(0));
      expect(stats.oldestHash, isNull);
      expect(stats.newestHash, isNull);
      expect(stats.averageAge, equals(Duration.zero));
      
      // Add some hashes
      await dedupeService.storeHash('1010101100110011010101011001100110101010110011001101010101100110');
      await Future.delayed(const Duration(milliseconds: 1)); // Ensure different timestamps
      await dedupeService.storeHash('0101010011001100101010100110011001010101001100110010101010011001');
      
      stats = dedupeService.getStatistics();
      expect(stats.totalHashes, equals(2));
      expect(stats.oldestHash, isNotNull);
      expect(stats.newestHash, isNotNull);
      expect(stats.oldestHash!.isBefore(stats.newestHash!), isTrue);
    });
    
    test('should cleanup old hashes', () async {
      // Store hashes with different ages (simulated by modifying cache directly)
      final String hashId1 = await dedupeService.storeHash('1010101100110011010101011001100110101010110011001101010101100110');
      final String hashId2 = await dedupeService.storeHash('0101010011001100101010100110011001010101001100110010101010011001');
      
      expect(dedupeService.getAllHashes().length, equals(2));
      
      // Cleanup with very short max age (should remove all)
      final int removed = await dedupeService.cleanupOldHashes(const Duration(microseconds: 1));
      expect(removed, equals(2));
      expect(dedupeService.getAllHashes().length, equals(0));
    });
    
    test('should sort matches by hamming distance', () async {
      const String baseHash = '1010101100110011010101011001100110101010110011001101010101100110';
      const String closeHash = '1010101100110011010101011001100110101010110011001101010101100111'; // 1 bit diff
      const String farHash = '1010101100110011010101011001100110101010110011001101010101100000'; // 2 bits diff
      
      // Store hashes in random order
      await dedupeService.storeHash(farHash, imagePath: '/far.jpg');
      await dedupeService.storeHash(closeHash, imagePath: '/close.jpg');
      
      final DuplicateCheckResult result = await dedupeService.checkDuplicate(baseHash);
      
      expect(result.allMatches.length, equals(2));
      expect(result.allMatches[0].hammingDistance, equals(1)); // Closest first
      expect(result.allMatches[1].hammingDistance, equals(2)); // Farther second
      expect(result.bestMatch, equals(result.allMatches[0]));
    });
    
    test('should use custom hamming threshold', () async {
      final DedupeService customService = DedupeService(hammingThreshold: 1);
      await customService.initialize();
      
      const String originalHash = '1010101100110011010101011001100110101010110011001101010101100110';
      const String similarHash = '1010101100110011010101011001100110101010110011001101010101100111'; // 1 bit diff
      const String differentHash = '1010101100110011010101011001100110101010110011001101010101101111'; // 2 bits diff
      
      await customService.storeHash(originalHash);
      
      // Should detect 1-bit difference
      DuplicateCheckResult result = await customService.checkDuplicate(similarHash);
      expect(result.isDuplicate, isTrue);
      
      // Should not detect 2-bit difference (threshold is 1)
      result = await customService.checkDuplicate(differentHash);
      expect(result.isDuplicate, isFalse);
    });
    
    test('ImageHashRecord should serialize and deserialize correctly', () {
      final DateTime now = DateTime.now();
      final ImageHashRecord original = ImageHashRecord(
        id: 'test_id',
        hash: '1010101100110011010101011001100110101010110011001101010101100110',
        imagePath: '/test/image.jpg',
        timestamp: now,
      );
      
      final Map<String, dynamic> json = original.toJson();
      final ImageHashRecord deserialized = ImageHashRecord.fromJson(json);
      
      expect(deserialized.id, equals(original.id));
      expect(deserialized.hash, equals(original.hash));
      expect(deserialized.imagePath, equals(original.imagePath));
      expect(deserialized.timestamp, equals(original.timestamp));
    });
    
    test('DuplicateMatch should have proper string representation', () {
      final DuplicateMatch match = DuplicateMatch(
        hashId: 'test_id',
        hash: '1010101100110011010101011001100110101010110011001101010101100110',
        hammingDistance: 5,
        imagePath: '/test.jpg',
        timestamp: DateTime.now(),
        similarity: 92.2,
      );
      
      final String representation = match.toString();
      expect(representation, contains('test_id'));
      expect(representation, contains('5'));
      expect(representation, contains('92.2%'));
    });
    
    test('DuplicateCheckResult should have proper string representation', () {
      final DuplicateMatch match = DuplicateMatch(
        hashId: 'test_id',
        hash: '1010101100110011010101011001100110101010110011001101010101100110',
        hammingDistance: 3,
        imagePath: '/test.jpg',
        timestamp: DateTime.now(),
        similarity: 95.3,
      );
      
      final DuplicateCheckResult result = DuplicateCheckResult(
        isDuplicate: true,
        bestMatch: match,
        allMatches: [match],
        checkedHash: 'test_hash',
        hammingThreshold: 8,
      );
      
      final String representation = result.toString();
      expect(representation, contains('true'));
      expect(representation, contains('1'));
      expect(representation, contains('95.3%'));
    });
    
    test('DedupeException should have proper string representation', () {
      const DedupeException exception = DedupeException('TEST_CODE', 'Test message');
      expect(exception.toString(), equals('DedupeException(TEST_CODE): Test message'));
    });
  });
}