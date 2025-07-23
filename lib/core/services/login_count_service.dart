// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// class LoginCountService {
//   final _storage = const FlutterSecureStorage();
//   static const String _loginCountKey = 'login_count';
//
//   /// Increment login count by 1 and return the new count
//   Future<int> incrementLoginCount() async {
//     final currentCount = await getLoginCount();
//     final newCount = currentCount + 1;
//     await _storage.write(key: _loginCountKey, value: newCount.toString());
//     return newCount;
//   }
//
//   /// Get current login count (returns 0 if not set)
//   Future<int> getLoginCount() async {
//     final countString = await _storage.read(key: _loginCountKey);
//     return int.tryParse(countString ?? '') ?? 0;
//   }
//
//   /// Reset login count to 0
//   Future<void> resetLoginCount() async {
//     await _storage.write(key: _loginCountKey, value: '0');
//   }
//
//   /// Delete login count from storage
//   Future<void> deleteLoginCount() async {
//     await _storage.delete(key: _loginCountKey);
//   }
// }
// lib/core/services/login_count_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginCountService {
  final _storage = const FlutterSecureStorage();
  static const String loginCountKey = 'logincount';

  /// Increment login count by 1 and return the new count
  Future<int> incrementLoginCount() async {
    final currentCount = await getLoginCount();
    final newCount = currentCount + 1;
    await _storage.write(key: loginCountKey, value: newCount.toString());
    return newCount;
  }

  /// Get current login count (returns 0 if not set)
  Future<int> getLoginCount() async {
    final countString = await _storage.read(key: loginCountKey);
    return int.tryParse(countString ?? '') ?? 0;
  }

  /// Reset login count to 0
  Future<void> resetLoginCount() async {
    await _storage.write(key: loginCountKey, value: '0');
  }

  /// Delete login count from storage
  Future<void> deleteLoginCount() async {
    await _storage.delete(key: loginCountKey);
  }
}
