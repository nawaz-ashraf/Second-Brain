import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlock;
  final bool isSettingPin;
  
  const PinLockScreen({
    super.key,
    required this.onUnlock,
    this.isSettingPin = false,
  });

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _error;
  Timer? _lockoutTimer;
  int _remainingLockout = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.isSettingPin) {
      _checkLockout();
    }
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _checkLockout() {
    final lockService = ref.read(appLockServiceProvider);
    final remaining = lockService.remainingLockoutSeconds;
    if (remaining > 0) {
      setState(() {
        _remainingLockout = remaining;
      });
      _startLockoutTimer();
    }
  }

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingLockout > 0) {
        setState(() {
          _remainingLockout--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onDigitPress(String digit) {
    if (_remainingLockout > 0) return;
    
    setState(() {
      _error = null;
      if (_isConfirming) {
        if (_confirmPin.length < 4) {
          _confirmPin += digit;
        }
        if (_confirmPin.length == 4) {
          _verifyConfirmPin();
        }
      } else {
        if (_pin.length < 4) {
          _pin += digit;
        }
        if (_pin.length == 4) {
          if (widget.isSettingPin) {
            _isConfirming = true;
          } else {
            _verifyPin();
          }
        }
      }
    });
  }

  void _onDeletePress() {
    if (_remainingLockout > 0) return;

    setState(() {
      _error = null;
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _isConfirming = false;
          _pin = _pin.substring(0, _pin.length - 1);
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  void _verifyPin() {
    final lockService = ref.read(appLockServiceProvider);
    if (lockService.verifyPin(_pin)) {
      widget.onUnlock();
    } else {
      setState(() {
        _error = 'Incorrect PIN';
        _pin = '';
      });
      _checkLockout();
    }
  }

  void _verifyConfirmPin() async {
    if (_pin == _confirmPin) {
      final lockService = ref.read(appLockServiceProvider);
      await lockService.setPin(_pin);
      widget.onUnlock();
    } else {
      setState(() {
        _error = 'PINs do not match. Try again.';
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activePin = _isConfirming ? _confirmPin : _pin;
    final title = widget.isSettingPin
        ? (_isConfirming ? 'Confirm PIN' : 'Set a 4-digit PIN')
        : 'Enter PIN';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: widget.isSettingPin
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_error != null)
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              )
            else if (_remainingLockout > 0)
              Text(
                'Try again in $_remainingLockout seconds',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              )
            else
              const Text(' '),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < activePin.length
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                  ),
                );
              }),
            ),
            const SizedBox(height: 64),
            _buildKeypad(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(ThemeData theme) {
    return Column(
      children: [
        _buildRow(theme, ['1', '2', '3']),
        const SizedBox(height: 16),
        _buildRow(theme, ['4', '5', '6']),
        const SizedBox(height: 16),
        _buildRow(theme, ['7', '8', '9']),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 80),
            _buildKey(theme, '0'),
            SizedBox(
              width: 80,
              child: IconButton(
                icon: const Icon(Icons.backspace_outlined),
                onPressed: _onDeletePress,
                color: theme.colorScheme.onSurface,
                iconSize: 28,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(ThemeData theme, List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.map((digit) {
        return _buildKey(theme, digit);
      }).toList(),
    );
  }

  Widget _buildKey(ThemeData theme, String digit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 72,
      height: 72,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _onDigitPress(digit),
          child: Center(
            child: Text(
              digit,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
