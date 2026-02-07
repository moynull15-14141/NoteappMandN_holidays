class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

class StorageException extends AppException {
  StorageException({required super.message, super.code});
}

class AuthenticationException extends AppException {
  AuthenticationException({required super.message, super.code});
}

class ImageException extends AppException {
  ImageException({required super.message, super.code});
}

class ExportException extends AppException {
  ExportException({required super.message, super.code});
}
