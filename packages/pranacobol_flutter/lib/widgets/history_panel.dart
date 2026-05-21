import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/breath_model.dart';

class HistoryPanel extends StatelessWidget {
  final bool isLocked;
  final List<SessionRecord> sessions;

  const HistoryPanel({
    super.key,
    required this.isLocked,
    required this.sessions,
  });

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
        children: [
          // Panel Title
          Row(
            children: [
              Icon(
                Icons.history,
                color: isLocked ? Colors.white.withOpacity(0.4) : const Color(0xFF06B6D4),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Completed Sessions',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // History content container
          Expanded(
            child: Stack(
              children: [
                // Sessions list (rendered when unlocked or behind blur)
                _buildSessionsTable(),
                
                // Locked Blur Overlay
                if (isLocked)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          color: const Color(0x6611162B).withOpacity(0.4),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '🔒',
                                style: const TextStyle(fontSize: 48),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'History Vault Locked',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Verify your passcode PIN in the security locker to view your saved session records.',
                                textAlign: centerOrJustify(context),
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.6),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextAlign centerOrJustify(BuildContext context) {
    return TextAlign.center;
  }

  Widget _buildSessionsTable() {
    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          'No sessions completed yet.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: Color(0xFF6B7280),
            fontSize: 13,
          ),
        ),
      );
    }

    // Render in reverse chronological order
    final reversedSessions = sessions.reversed.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.6),
          ),
          dataTextStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            color: Colors.white,
          ),
          columnSpacing: 24,
          horizontalMargin: 8,
          dividerThickness: 0.5,
          columns: const [
            DataColumn(label: Text('Date/Time')),
            DataColumn(label: Text('Method')),
            DataColumn(label: Text('Duration')),
            DataColumn(label: Text('Notes')),
          ],
          rows: reversedSessions.map((sess) {
            return DataRow(
              cells: [
                DataCell(Text(sess.time)),
                DataCell(Text(
                  sess.method,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                )),
                DataCell(Text(
                  '${sess.duration}s',
                  style: const TextStyle(
                    fontFamily: 'Share Tech Mono',
                    color: Color(0xFF06B6D4),
                  ),
                )),
                DataCell(
                  Container(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: Text(
                      sess.notes.isEmpty ? '—' : sess.notes,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
