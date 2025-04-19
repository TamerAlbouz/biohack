// Interface
import '../models/rate_limiter_result.dart';

abstract class IRateLimiter {
  Future<RateLimitResult> checkRateLimit({
    required String key,
    required int maxAttempts,
    required Duration windowDuration,
  });

  Future<void> recordAttempt({required String key});

  Future<void> reset({required String key});
}
