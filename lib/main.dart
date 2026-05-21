import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/breath_model.dart';
import 'services/api_service.dart';
import 'widgets/breathing_ring.dart';
import 'widgets/notes_modal.dart';
import 'widgets/history_panel.dart';
import 'widgets/security_panel.dart';

void main() {
  runApp(const PranaCobolApp());
}

class PranaCobolApp extends StatelessWidget {
  const PranaCobolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PranaCOBOL - Breathwork & Security Locker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF060814),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  
  // App state variables
  List<BreathingMethod> _methods = [];
  int _activeMethodIndex = 0;
  
  bool _isBreathing = false;
  int _breathingSecondsElapsed = 0;
  int _phaseIndex = 0; // 0: inhale, 1: hold, 2: exhale, 3: holdOut
  int _currentPhaseTimer = 0;
  int _totalCyclesCount = 0;
  Timer? _breathingTimer;

  ServerStatus? _serverStatus;
  List<SessionRecord> _sessions = [];
  bool _isServerLocked = true;
  bool _isOffline = false;
  bool _isLoading = true;
  String? _pinErrorMessage;

  Timer? _statusPollTimer;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Fetch methods and initial status
      await _fetchMethods();
      await _fetchServerStatus();
      await _fetchSessions();
      setState(() {
        _isOffline = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isOffline = true;
        _isLoading = false;
      });
      _showToast('Connection Error', 'Could not reach COBOL backend server.', isError: true);
    }

    // Start periodic polling for server status/uptime
    _statusPollTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      _fetchServerStatus();
    });
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel();
    _breathingTimer?.cancel();
    super.dispose();
  }

  // --- API Integrations ---

  Future<void> _fetchMethods() async {
    try {
      final methodsList = await _apiService.fetchMethods();
      setState(() {
        _methods = methodsList;
      });
    } catch (e) {
      debugPrint('Error fetching methods: $e');
    }
  }

  Future<void> _fetchServerStatus() async {
    try {
      final status = await _apiService.fetchStatus();
      final previousLockState = _isServerLocked;
      
      setState(() {
        _serverStatus = status;
        _isServerLocked = status.isLocked;
        _isOffline = false;
      });

      // If lock status changed on server, refresh sessions
      if (previousLockState != _isServerLocked) {
        _fetchSessions();
      }
    } catch (e) {
      if (!_isOffline) {
        setState(() {
          _isOffline = true;
        });
        _showToast('Server Offline', 'Lost connection to COBOL server.', isError: true);
      }
    }
  }

  Future<void> _fetchSessions() async {
    try {
      final data = await _apiService.fetchSessions();
      setState(() {
        _isServerLocked = data['locked'] as bool? ?? true;
        _sessions = data['sessions'] as List<SessionRecord>? ?? [];
      });
    } catch (e) {
      debugPrint('Error fetching sessions: $e');
    }
  }

  // --- Actions ---

  Future<void> _handleUnlock(String pin) async {
    final result = await _apiService.toggleLock(pin);
    if (result['success'] == true) {
      setState(() {
        _isServerLocked = result['state'] == 'LOCKED';
        _pinErrorMessage = null;
      });
      await _fetchSessions();
      _showToast('Vault Unlocked', 'Your breathing log database is now visible.');
    } else {
      setState(() {
        _pinErrorMessage = 'Invalid passcode PIN';
      });
      _showToast('Auth Failed', result['error'] ?? 'Incorrect passcode PIN.', isError: true);
    }
  }

  Future<void> _handleLock() async {
    final result = await _apiService.toggleLock('');
    if (result['success'] == true) {
      setState(() {
        _isServerLocked = result['state'] == 'LOCKED';
        _pinErrorMessage = null;
        _sessions = [];
      });
      _showToast('Vault Locked', 'Your breathing logs are now secure.');
    } else {
      _showToast('Lock Failed', 'Could not lock the database.', isError: true);
    }
  }

  Future<void> _handleReset(String pin) async {
    final result = await _apiService.resetSessions(pin);
    if (result['success'] == true) {
      _showToast('Logs Reset', 'All database history records have been cleared.');
      await _fetchSessions();
    } else {
      _showToast('Reset Failed', result['error'] ?? 'Incorrect PIN passcode.', isError: true);
    }
  }

  Future<void> _saveSession(String notes) async {
    final method = _methods[_activeMethodIndex];
    try {
      final success = await _apiService.saveSession(method.name, _breathingSecondsElapsed, notes);
      if (success) {
        _showToast('Session Saved', 'Logged practice to the COBOL database.');
        await _fetchSessions();
      } else {
        _showToast('Saving Failed', 'COBOL server rejected the database entry.', isError: true);
      }
    } catch (e) {
      _showToast('Connection Error', 'Could not send session data to backend.', isError: true);
    }
  }

  // --- Breathing State Machine ---

  void _startBreathing() {
    if (_methods.isEmpty) return;
    
    setState(() {
      _isBreathing = true;
      _breathingSecondsElapsed = 0;
      _phaseIndex = 0;
      _totalCyclesCount = 0;
    });

    _runPhase();
  }

  void _stopBreathing() {
    _breathingTimer?.cancel();
    
    if (_breathingSecondsElapsed < 5) {
      _showToast('Practice Too Short', 'Sessions shorter than 5 seconds are not logged.', isError: true);
      setState(() {
        _isBreathing = false;
      });
      return;
    }

    // Show modal dialog to add notes
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return NotesModal(
          methodName: _methods[_activeMethodIndex].name,
          durationSeconds: _breathingSecondsElapsed,
          onSave: (notes) {
            Navigator.of(context).pop();
            _saveSession(notes);
            setState(() {
              _isBreathing = false;
            });
          },
          onDiscard: () {
            Navigator.of(context).pop();
            _showToast('Session Discarded', 'Your breathwork session was not logged.', isError: true);
            setState(() {
              _isBreathing = false;
            });
          },
        );
      },
    );
  }

  void _runPhase() {
    if (!_isBreathing || _methods.isEmpty) return;

    final method = _methods[_activeMethodIndex];
    final phases = [
      {'name': 'Inhale', 'duration': method.inhale, 'type': 'inhale'},
      {'name': 'Hold', 'duration': method.hold, 'type': 'hold'},
      {'name': 'Exhale', 'duration': method.exhale, 'type': 'exhale'},
      {'name': 'Hold Out', 'duration': method.holdOut, 'type': 'holdOut'}
    ];

    // Skip phases with 0 duration
    while (phases[_phaseIndex]['duration'] == 0) {
      _phaseIndex = (_phaseIndex + 1) % 4;
      if (_phaseIndex == 0) {
        _totalCyclesCount++;
      }
    }

    setState(() {
      _currentPhaseTimer = phases[_phaseIndex]['duration'] as int;
    });

    _tick();
  }

  void _tick() {
    _breathingTimer?.cancel();
    _breathingTimer = Timer(const Duration(seconds: 1), () {
      if (!_isBreathing) return;

      setState(() {
        _breathingSecondsElapsed++;
        _currentPhaseTimer--;
      });

      if (_currentPhaseTimer <= 0) {
        // Transition to next phase
        _phaseIndex = (_phaseIndex + 1) % 4;
        if (_phaseIndex == 0) {
          _totalCyclesCount++;
        }
        _runPhase();
      } else {
        _tick();
      }
    });
  }

  // --- Helper Methods ---

  String _formatUptime(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _showToast(String title, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        content: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xEE0F1322),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isError ? const Color(0xFFF43F5E).withOpacity(0.4) : const Color(0xFF10B981).withOpacity(0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.close : Icons.check,
                  color: isError ? const Color(0xFFF43F5E) : const Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Rendering UI ---

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
          ),
        ),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 950;

    return Scaffold(
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06B6D4).withOpacity(0.06), // Cyan ambient spot
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withOpacity(0.08),
                    blurRadius: 150,
                    spreadRadius: 60,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.06), // Purple ambient spot
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.08),
                    blurRadius: 150,
                    spreadRadius: 60,
                  )
                ],
              ),
            ),
          ),
          
          // Main Scrollable Body
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1300),
                        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
                      ),
                    ),
                  ),
                ),
                
                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final statusText = _isOffline ? 'OFFLINE' : 'ONLINE';
    final statusColor = _isOffline ? const Color(0xFFF43F5E) : const Color(0xFF10B981);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Row(
                children: [
                  Text(
                    'PranaCOBOL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
                    ),
                    child: Text(
                      'v3.2',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 10,
                        color: const Color(0xFF06B6D4),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Server Statistics
              Row(
                children: [
                  _buildHeaderStat(
                    'Uptime',
                    _serverStatus != null ? _formatUptime(_serverStatus!.uptimeSeconds) : '00:00:00',
                  ),
                  const SizedBox(width: 24),
                  _buildHeaderStat(
                    'Total Requests',
                    _serverStatus != null ? '${_serverStatus!.requestCount}' : '0',
                  ),
                  const SizedBox(width: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: statusColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'COBOL $statusText',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.4),
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.shareTechMono(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Breathing Panel
        Expanded(
          flex: 3,
          child: _buildBreathingPanel(),
        ),
        const SizedBox(width: 24),
        // Right Column: Sidebar Panels (Security & History)
        Expanded(
          flex: 2,
          child: Column(
            children: [
              SecurityPanel(
                isLocked: _isServerLocked,
                errorMessage: _pinErrorMessage,
                onUnlock: _handleUnlock,
                onLock: _handleLock,
                onReset: _handleReset,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 400,
                child: HistoryPanel(
                  isLocked: _isServerLocked,
                  sessions: _sessions,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildBreathingPanel(),
        const SizedBox(height: 24),
        SecurityPanel(
          isLocked: _isServerLocked,
          errorMessage: _pinErrorMessage,
          onUnlock: _handleUnlock,
          onLock: _handleLock,
          onReset: _handleReset,
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 380,
          child: HistoryPanel(
            isLocked: _isServerLocked,
            sessions: _sessions,
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingPanel() {
    final method = _methods.isNotEmpty ? _methods[_activeMethodIndex] : null;
    final String phaseName;
    final int secondsRemaining;
    final String phaseType;
    final int phaseDuration;

    if (_isBreathing && method != null) {
      final phases = [
        {'name': 'Inhale', 'duration': method.inhale, 'type': 'inhale'},
        {'name': 'Hold', 'duration': method.hold, 'type': 'hold'},
        {'name': 'Exhale', 'duration': method.exhale, 'type': 'exhale'},
        {'name': 'Hold Out', 'duration': method.holdOut, 'type': 'holdOut'}
      ];
      phaseName = phases[_phaseIndex]['name'] as String;
      secondsRemaining = _currentPhaseTimer;
      phaseType = phases[_phaseIndex]['type'] as String;
      phaseDuration = phases[_phaseIndex]['duration'] as int;
    } else {
      phaseName = 'Ready';
      secondsRemaining = 0;
      phaseType = 'idle';
      phaseDuration = 0;
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0x6611162B), // Glassmorphic background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          // Breathing Methods Selector Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_methods.length, (index) {
                final m = _methods[index];
                final isActive = index == _activeMethodIndex;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: _isBreathing
                        ? null
                        : () {
                            setState(() {
                              _activeMethodIndex = index;
                            });
                          },
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF8B5CF6)
                            : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF8B5CF6).withOpacity(0.4)
                              : Colors.white.withOpacity(0.07),
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        m.name,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),

          // Breathing ring guided center
          BreathingRing(
            phaseName: phaseName,
            secondsRemaining: secondsRemaining,
            phaseType: phaseType,
            phaseDuration: phaseDuration,
          ),
          const SizedBox(height: 24),

          // Breathing instructions and cycle info
          Container(
            height: 48,
            alignment: Alignment.center,
            child: Text(
              _isBreathing
                  ? 'Active Practice • Cycles completed: $_totalCyclesCount • Total elapsed: ${_breathingSecondsElapsed}s'
                  : (method != null
                      ? '${method.name}: ${method.inhale}s Inhale / ${method.hold}s Hold / ${method.exhale}s Exhale / ${method.holdOut}s Hold Out.'
                      : 'Select a method above to begin'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action start/stop buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isBreathing)
                Container(
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
                  child: ElevatedButton.icon(
                    onPressed: _startBreathing,
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: const Text(
                      'Start Session',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _stopBreathing,
                  icon: const Icon(Icons.stop, color: Colors.white),
                  label: const Text(
                    'Finish & Save',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Center(
        child: Text(
          '© 2026 PranaCOBOL. Guided breathwork server built with standard GnuCOBOL and POSIX sockets.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
