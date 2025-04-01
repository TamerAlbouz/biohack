import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:p_logger/p_logger.dart';

import '../interfaces/rate_limiter_interface.dart';
import '../models/rate_limiter_result.dart';

@LazySingleton(as: IRateLimiter)
class RateLimiter implements IRateLimiter {
  final FirebaseFirestore _firestore;

  RateLimiter(this._firestore);

  @override
  Future<RateLimitResult> checkRateLimit({
    required String key,
    required int maxAttempts,
    required Duration windowDuration,
  }) async {
    // Use transaction to ensure atomic read/write
    return _firestore.runTransaction<RateLimitResult>((transaction) async {
      final docRef = _firestore.collection('rateLimits').doc(key);
      final doc = await transaction.get(docRef);

      if (!doc.exists) {
        return RateLimitResult(allowed: true, timeRemaining: Duration.zero);
      }

      final data = doc.data()!;
      final attempts = data['attempts'] as int;
      final windowStart = (data['windowStart'] as Timestamp).toDate();
      final now = DateTime.now();

      if (now.difference(windowStart) > windowDuration) {
        // Window expired, will be reset on next attempt
        return RateLimitResult(allowed: true, timeRemaining: Duration.zero);
      }

      if (attempts >= maxAttempts) {
        final timeRemaining = windowDuration - now.difference(windowStart);
        return RateLimitResult(allowed: false, timeRemaining: timeRemaining);
      }

      return RateLimitResult(allowed: true, timeRemaining: Duration.zero);
    });
  }

  @override
  Future<void> recordAttempt({required String key}) async {
    logger.i('Recording attempt for $key');
    final docRef = _firestore.collection('rateLimits').doc(key);

    logger.i('Running transaction');
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      final now = DateTime.now();

      if (!doc.exists) {
        logger.i('Creating new rate limit document');
        transaction.set(docRef, {
          'attempts': 1,
          'windowStart': Timestamp.fromDate(now),
        });
        return;
      }

      final data = doc.data()!;
      final windowStart = (data['windowStart'] as Timestamp).toDate();

      // If window has expired, start a new one
      if (now.difference(windowStart) > const Duration(hours: 1)) {
        logger.i("Window expired. Starting new one");
        transaction.set(docRef, {
          'attempts': 1,
          'windowStart': Timestamp.fromDate(now),
        });
        return;
      } else {
        logger.i("Window still active. Incrementing attempts");
        // Increment attempts in current window
        transaction.update(docRef, {
          'attempts': FieldValue.increment(1),
        });
        return;
      }
    });
  }

  @override
  Future<void> reset({required String key}) async {
    await _firestore.collection('rateLimits').doc(key).delete();
  }
}
