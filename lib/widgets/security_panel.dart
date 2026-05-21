import 'package:flutter/material.dart';

class SecurityPanel extends StatefulWidget {
  final bool isLocked;
  final Function(String pin) onUnlock;
  final VoidCallback onLock;
  final Function(String pin) onReset;
  final String? errorMessage;

  const SecurityPanel({
    super.key,
    required this.isLocked,
    required this.onUnlock,
    required this.onLock,
    required this.onReset,
    this.errorMessage,
  });

  @override
  State<SecurityPanel> createState() => _SecurityPanelState();
}

class _SecurityPanelState extends State<SecurityPanel> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SecurityPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLocked && !oldWidget.isLocked) {
      _clearFields();
    }
  }

  void _clearFields() {
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  String _getPin() {
    return _controllers.map((c) => c.text).join();
  }

  void _submit() {
    final pin = _getPin();
    if (pin.length == 4) {
      widget.onUnlock(pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x6611162B), // Glassmorphic background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    widget.isLocked ? Icons.lock : Icons.lock_open,
                    color: widget.isLocked ? const Color(0xFFF43F5E) : const Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Session Locker',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isLocked
                      ? const Color(0xFFF43F5E).withOpacity(0.1)
                      : const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: widget.isLocked
                        ? const Color(0xFFF43F5E).withOpacity(0.2)
                        : const Color(0xFF10B981).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  widget.isLocked ? 'LOCKED' : 'UNLOCKED',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.isLocked ? const Color(0xFFF43F5E) : const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main locker section
          if (widget.isLocked) ...[
            Center(
              child: Text(
                widget.errorMessage ?? 'Enter PIN to Unlock Session Logs',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: widget.errorMessage != null ? const Color(0xFFF43F5E) : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 4 digit PIN textfields
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(
                      fontFamily: 'Share Tech Mono',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.03),
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.07)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6)), // Purple accent
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        if (index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        } else {
                          _focusNodes[index].unfocus();
                          _submit();
                        }
                      } else {
                        if (index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            
            // Unlock button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Unlock History',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            const Center(
              child: Text(
                'History is currently visible',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Color(0xFF10B981), // Emerald accent
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Unlocked Controls
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onLock,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white.withOpacity(0.05),
                      foregroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.07)),
                      ),
                    ),
                    child: const Text(
                      'Lock History',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      // Prompt for PIN to confirm reset
                      final confirmPin = await _showResetConfirmDialog(context);
                      if (confirmPin != null) {
                        widget.onReset(confirmPin);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0x66F43F5E)), // Translucent rose
                      foregroundColor: const Color(0xFFF43F5E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Clear Log',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<String?> _showResetConfirmDialog(BuildContext context) {
    final TextEditingController pinConfirmController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1322),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirm Database Reset',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF43F5E), // Rose color
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This action will permanently delete all session history records. Please enter the lock PIN passcode to confirm:',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: pinConfirmController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  autofocus: true,
                  style: const TextStyle(
                    fontFamily: 'Share Tech Mono',
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter 4-digit PIN',
                    hintStyle: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      letterSpacing: 0,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.02),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.07)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFF43F5E)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.white.withOpacity(0.03),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.white.withOpacity(0.07)),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final pin = pinConfirmController.text.trim();
                          Navigator.of(context).pop(pin.isEmpty ? null : pin);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF43F5E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Reset Now',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
