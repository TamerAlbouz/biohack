class RateLimitResult {
  final bool allowed;
  final Duration timeRemaining;

  RateLimitResult({
    required this.allowed,
    required this.timeRemaining,
  });
}
