class BaseException implements Exception {
  final String message;

  const BaseException([this.message = 'An unknown exception occurred.']);

  /// A method to create an exception from a specific code.
  static String fromCode(String code) {
    switch (code) {
      case 'aborted':
        return 'The operation was aborted, typically due to a concurrency issue like transaction aborts.';
      case 'already-exists':
        'A document that was attempted to be created already exists.';
      case 'cancelled':
        return 'The operation was cancelled, typically by the caller.';

      case 'data-loss':
        return 'Unrecoverable data loss or corruption occurred.';

      case 'deadline-exceeded':
        return 'The deadline expired before the operation could complete.';

      case 'failed-precondition':
        return 'The operation was rejected because the system is not in a state required for its execution.';

      case 'internal':
        return 'An internal error occurred. Something is very broken.';

      case 'invalid-argument':
        return 'An invalid argument was specified by the client.';

      case 'not-found':
        return 'The requested document was not found.';

      case 'ok':
        return 'The operation completed successfully.';

      case 'out-of-range':
        return 'The operation was attempted past the valid range.';

      case 'permission-denied':
        return 'The caller does not have permission to execute the operation.';

      case 'resource-exhausted':
        return 'A resource has been exhausted; such as a quota or storage space.';

      case 'unauthenticated':
        return 'The request does not have valid authentication credentials.';

      case 'unavailable':
        return 'The service is currently unavailable. Please try again later.';

      case 'unimplemented':
        return 'The operation is not implemented or supported.';

      case 'unknown':
        return 'An unknown error occurred; or the error comes from a different domain.';

      default:
        return 'An unspecified error occurred.';
    }
    return "An unspecified error occurred.";
  }
}
