class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException()
      : super("No internet connection.");
}

class RequestTimeoutException extends ApiException {
  const RequestTimeoutException()
      : super("The request timed out.");
}

class SessionExpiredException extends ApiException {
  const SessionExpiredException()
      : super("Your session has expired.");
}