import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appLockServiceProvider = Provider<AppLockService>((ref) {
  throw UnimplementedError('Initialized in main');
});

class AppLockService {
  final SharedPreferences _prefs;

  static const String _pinKey = 'app_lock_pin';
  static const String _isEnabledKey = 'app_lock_enabled';
  static const String _failedAttemptsKey = 'app_lock_failed_attempts';
  static const String _lockoutTimeKey = 'app_lock_lockout_time';

  AppLockService(this._prefs);

  bool get isEnabled => _prefs.getBool(_isEnabledKey) ?? false;
  
  bool get isLockedOut {
    final lockoutTime = _prefs.getInt(_lockoutTimeKey);
    if (lockoutTime != null) {
      final lockoutEndTime = DateTime.fromMillisecondsSinceEpoch(lockoutTime);
      if (DateTime.now().isBefore(lockoutEndTime)) {
        return true;
      } else {
        // Lockout expired, reset failed attempts
        _prefs.remove(_lockoutTimeKey);
        _prefs.remove(_failedAttemptsKey);
        return false;
      }
    }
    return false;
  }

  Future<void> setPin(String pin) async {
    await _prefs.setString(_pinKey, pin);
    await _prefs.setBool(_isEnabledKey, true);
    await _prefs.remove(_failedAttemptsKey);
    await _prefs.remove(_lockoutTimeKey);
  }

  Future<void> disableLock() async {
    await _prefs.remove(_pinKey);
    await _prefs.setBool(_isEnabledKey, false);
    await _prefs.remove(_failedAttemptsKey);
    await _prefs.remove(_lockoutTimeKey);
  }

  bool verifyPin(String pin) {
    if (isLockedOut) return false;

    final storedPin = _prefs.getString(_pinKey);
    if (storedPin == pin) {
      _prefs.remove(_failedAttemptsKey);
      return true;
    } else {
      _incrementFailedAttempts();
      return false;
    }
  }

  void _incrementFailedAttempts() {
    final failedAttempts = (_prefs.getInt(_failedAttemptsKey) ?? 0) + 1;
    _prefs.setInt(_failedAttemptsKey, failedAttempts);

    if (failedAttempts >= 5) {
      // Lockout for 5 minutes
      final lockoutTime = DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch;
      _prefs.setInt(_lockoutTimeKey, lockoutTime);
    }
  }

  int get remainingLockoutSeconds {
    final lockoutTime = _prefs.getInt(_lockoutTimeKey);
    if (lockoutTime == null) return 0;
    
    final end = DateTime.fromMillisecondsSinceEpoch(lockoutTime);
    final now = DateTime.now();
    
    if (end.isAfter(now)) {
      return end.difference(now).inSeconds;
    }
    return 0;
  }
}
