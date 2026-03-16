import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _playerCount = 2;
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers.clear();
    for (int i = 0; i < _playerCount; i++) {
      _controllers.add(TextEditingController(text: 'Player ${i + 1}'));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    final names = _controllers.map((c) {
      final v = c.text.trim();
      return v.isEmpty ? 'Player' : v;
    }).toList();

    context.read<GameProvider>().startGame(names, vsBot: _playerCount == 1);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    const Text(
                      '🧀',
                      style: TextStyle(fontSize: 64),
                    ).animate().scale(
                          duration: 800.ms,
                          curve: Curves.elasticOut,
                        ),
                    const SizedBox(height: 8),
                    const Text(
                      'All Cheese',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4E2C00),
                        letterSpacing: 2,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3),
                    const SizedBox(height: 4),
                    Text(
                      'The mouse who collects the most cheese wins!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.brown.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 36),

                    // Player count selector
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Number of players',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.brown.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int n = 1; n <= 6; n++)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _playerCount = n;
                                        _initControllers();
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _playerCount == n
                                            ? const Color(0xFFFFA000)
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: _playerCount == n
                                              ? Colors.brown.shade600
                                              : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: n == 1
                                            ? const Text(
                                                '🤖',
                                                style: TextStyle(fontSize: 20),
                                              )
                                            : Text(
                                                '$n',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _playerCount == n
                                                      ? Colors.white
                                                      : Colors.brown.shade600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (_playerCount == 1) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amber.shade400),
                              ),
                              child: Text(
                                'You vs Bot 🤖 — the bot plays automatically',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.brown.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          // Player name fields (human players only)
                          for (int i = 0; i < _playerCount; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: TextField(
                                controller: _controllers[i],
                                decoration: InputDecoration(
                                  prefixText: '🐭  ',
                                  labelText: _playerCount == 1
                                      ? 'Your name'
                                      : 'Player ${i + 1} name',
                                  filled: true,
                                  fillColor: Colors.amber.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.amber.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.brown.shade500,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_playerCount == 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Row(
                                  children: [
                                    Text('🤖', style: TextStyle(fontSize: 18)),
                                    SizedBox(width: 10),
                                    Text(
                                      'Bot 🤖',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                    const SizedBox(height: 28),

                    // Start button
                    ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E2C00),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                      ),
                      child: const Text(
                        'Start Game',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    // Quick rules
                    ExpansionTile(
                      title: Text(
                        'How to play',
                        style: TextStyle(
                          color: Colors.brown.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(bottom: 8),
                      children: [
                        _ruleText('🎲 Roll the dice to get a number (1–6)'),
                        _ruleText('❌ No match in pantry → peek at any card (memory!)'),
                        _ruleText('✅ Match found → Take the card or Remove it'),
                        _ruleText('🪤 Take 3 trap cards → eliminated!'),
                        _ruleText('🏆 Most cheese holes (on safe cards) wins'),
                        _ruleText('📦 Game also ends when the reserve runs out'),
                        if (_playerCount == 1)
                          _ruleText('🤖 Bot uses memory to make smarter decisions'),
                        // total players = _playerCount + (vsBot ? 1 : 0)
                        if (_playerCount + (_playerCount == 1 ? 1 : 0) <= 3)
                          _ruleText(
                              '⚡ ${_playerCount + (_playerCount == 1 ? 1 : 0)}-player game: 1 extra reserve card removed per turn'),
                      ],
                    ).animate().fadeIn(delay: 900.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ruleText(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          text,
          style: TextStyle(fontSize: 13, color: Colors.brown.shade800),
        ),
      );
}
