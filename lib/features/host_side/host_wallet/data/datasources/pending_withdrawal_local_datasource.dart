import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/pending_withdrawal_request.dart';

/// Persists the one withdrawal request whose outcome is unknown, so its
/// `Idempotency-Key` and body survive an app restart. Scoped per user —
/// logout doesn't wipe arbitrary secure-storage keys, and another host on
/// the same device must never replay this one's request.
abstract class PendingWithdrawalLocalDataSource {
  Future<PendingWithdrawalRequest?> read();
  Future<void> save(PendingWithdrawalRequest request);
  Future<void> clear();
}

@LazySingleton(as: PendingWithdrawalLocalDataSource)
class PendingWithdrawalLocalDataSourceImpl
    implements PendingWithdrawalLocalDataSource {
  final FlutterSecureStorage _storage;
  final IAuthLocalDataSource _authLocalDataSource;

  PendingWithdrawalLocalDataSourceImpl(
    this._storage,
    this._authLocalDataSource,
  );

  static const _keyPrefix = 'pending_withdrawal_request';

  Future<String> _storageKey() async {
    final userId = await _authLocalDataSource.getUserId() ?? '';
    return '${_keyPrefix}_$userId';
  }

  @override
  Future<PendingWithdrawalRequest?> read() async {
    try {
      final raw = await _storage.read(key: await _storageKey());
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic>
          ? PendingWithdrawalRequest.fromJson(decoded)
          : null;
    } catch (e) {
      appLogger.e('PendingWithdrawalLocalDataSource: read failed: $e');
      return null;
    }
  }

  @override
  Future<void> save(PendingWithdrawalRequest request) async {
    await _storage.write(
      key: await _storageKey(),
      value: jsonEncode(request.toJson()),
    );
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: await _storageKey());
    } catch (e) {
      appLogger.e('PendingWithdrawalLocalDataSource: clear failed: $e');
    }
  }
}
