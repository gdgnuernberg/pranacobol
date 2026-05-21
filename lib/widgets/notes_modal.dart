import 'package:flutter/material.dart';

class NotesModal extends StatefulWidget {
  final String methodName;
  final int durationSeconds;
  final Function(String notes) onSave;
  final VoidCallback onDiscard;

  const NotesModal({
    super.key,
    required this.methodName,
    required this.durationSeconds,
    required this.onSave,
    required this.onDiscard,
  });

  @override
  State<NotesModal> createState() => _NotesModalState();
}

class _NotesModalState extends State<NotesModal> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1322),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              spreadRadius: 5,
            )
          ],
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Complete!',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF06B6D4), // Cyan accent
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Excellent practice. Add optional journals or notes below to log this session to the COBOL database.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                height: 1.5,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            
            // Practice Name
            _buildFieldLabel('Completed Practice'),
            const SizedBox(height: 8),
            _buildDisabledInput(widget.methodName),
            const SizedBox(height: 16),
            
            // Duration
            _buildFieldLabel('Duration (seconds)'),
            const SizedBox(height: 8),
            _buildDisabledInput('${widget.durationSeconds}s'),
            const SizedBox(height: 16),
            
            // Notes Input
            _buildFieldLabel('Notes / Journal'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              autofocus: true,
              maxLength: 50,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'How do you feel? (e.g. relaxed, focused)',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.02),
                counterStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.07)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF06B6D4)),
                ),
              ),
              onSubmitted: (_) {
                widget.onSave(_notesController.text.trim());
              },
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: widget.onDiscard,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white.withOpacity(0.03),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.07)),
                      ),
                    ),
                    child: const Text(
                      'Discard',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF06B6D4).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onSave(_notesController.text.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Log Session',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Colors.white.withOpacity(0.5),
      ),
    );
  }

  Widget _buildDisabledInput(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
