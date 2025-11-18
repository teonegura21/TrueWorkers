/// Error types for the Mesteri Platform
/// Used to categorize errors and provide appropriate user feedback
enum ErrorType {
  network,
  authentication,
  validation,
  server,
  notFound,
  forbidden,
  timeout,
  unknown,
}

/// Application error class with user-friendly messages
class AppError {
  final ErrorType type;
  final String message;
  final String? technicalDetails;
  final bool canRetry;

  AppError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.canRetry = true,
  });

  /// Create an AppError from any exception
  factory AppError.fromException(dynamic exception) {
    // Handle null case
    if (exception == null) {
      return AppError(
        type: ErrorType.unknown,
        message: 'A apărut o eroare neașteptată.',
        canRetry: true,
      );
    }

    final exceptionString = exception.toString();

    // Network errors (SocketException, DioException with no internet)
    if (exceptionString.contains('SocketException') ||
        exceptionString.contains('Failed host lookup') ||
        exceptionString.contains('Network is unreachable')) {
      return AppError(
        type: ErrorType.network,
        message:
            'Nu s-a putut conecta la server. Verifică conexiunea la internet și încearcă din nou.',
        technicalDetails: exceptionString,
        canRetry: true,
      );
    }

    // Timeout errors
    if (exceptionString.contains('TimeoutException') ||
        exceptionString.contains('timed out')) {
      return AppError(
        type: ErrorType.timeout,
        message:
            'Conexiunea a expirat. Serverul nu răspunde. Te rugăm să încerci din nou.',
        technicalDetails: exceptionString,
        canRetry: true,
      );
    }

    // Authentication errors (401)
    if (exceptionString.contains('401') ||
        exceptionString.contains('Unauthorized') ||
        exceptionString.contains('user-not-found') ||
        exceptionString.contains('wrong-password')) {
      return AppError(
        type: ErrorType.authentication,
        message: 'Sesiunea ta a expirat. Te rugăm să te autentifici din nou.',
        technicalDetails: exceptionString,
        canRetry: false,
      );
    }

    // Forbidden errors (403)
    if (exceptionString.contains('403') ||
        exceptionString.contains('Forbidden')) {
      return AppError(
        type: ErrorType.forbidden,
        message: 'Nu ai permisiunea să accesezi această resursă.',
        technicalDetails: exceptionString,
        canRetry: false,
      );
    }

    // Not found errors (404)
    if (exceptionString.contains('404') ||
        exceptionString.contains('Not Found')) {
      return AppError(
        type: ErrorType.notFound,
        message: 'Resursa solicitată nu a fost găsită.',
        technicalDetails: exceptionString,
        canRetry: false,
      );
    }

    // Server errors (500, 502, 503)
    if (exceptionString.contains('500') ||
        exceptionString.contains('502') ||
        exceptionString.contains('503') ||
        exceptionString.contains('Internal Server Error') ||
        exceptionString.contains('Bad Gateway') ||
        exceptionString.contains('Service Unavailable')) {
      return AppError(
        type: ErrorType.server,
        message:
            'Serverul întâmpină probleme. Te rugăm să încerci din nou mai târziu.',
        technicalDetails: exceptionString,
        canRetry: true,
      );
    }

    // Validation errors
    if (exceptionString.contains('ValidationException') ||
        exceptionString.contains('invalid') ||
        exceptionString.contains('required')) {
      return AppError(
        type: ErrorType.validation,
        message: 'Datele introduse nu sunt valide. Te rugăm să verifici și să încerci din nou.',
        technicalDetails: exceptionString,
        canRetry: false,
      );
    }

    // Default unknown error
    return AppError(
      type: ErrorType.unknown,
      message: 'A apărut o eroare. Te rugăm să încerci din nou.',
      technicalDetails: exceptionString,
      canRetry: true,
    );
  }

  /// Create a network error
  factory AppError.network([String? details]) {
    return AppError(
      type: ErrorType.network,
      message:
          'Nu s-a putut conecta la server. Verifică conexiunea la internet.',
      technicalDetails: details,
      canRetry: true,
    );
  }

  /// Create an authentication error
  factory AppError.authentication([String? details]) {
    return AppError(
      type: ErrorType.authentication,
      message: 'Sesiunea ta a expirat. Te rugăm să te autentifici din nou.',
      technicalDetails: details,
      canRetry: false,
    );
  }

  /// Create a validation error
  factory AppError.validation(String message, [String? details]) {
    return AppError(
      type: ErrorType.validation,
      message: message,
      technicalDetails: details,
      canRetry: false,
    );
  }

  /// Create a server error
  factory AppError.server([String? details]) {
    return AppError(
      type: ErrorType.server,
      message: 'Serverul întâmpină probleme. Te rugăm să încerci din nou mai târziu.',
      technicalDetails: details,
      canRetry: true,
    );
  }

  @override
  String toString() => message;
}
