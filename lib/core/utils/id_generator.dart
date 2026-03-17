import 'package:uuid/uuid.dart';

/// Centralized ID generation for all entities.
abstract final class IdGenerator {
  static const _uuid = Uuid();

  /// Generates a new UUID v4 string.
  static String newId() => _uuid.v4();
}
