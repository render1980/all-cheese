import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/player_model.dart';
import '../providers/game_provider.dart';
import 'setup_screen.dart';
import 'game_screen.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    final rankings = game.rankings;
    final winner = rankings.first;

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
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    // Trophy / eliminated message
                    if (winner.player.isEliminated)
                      const Text('💀', style: TextStyle(fontSize: 64))
                          .animate()
                          .scale(duration: 600.ms, curve: Curves.elasticOut)
                    else
                      const Text('🏆', style: TextStyle(fontSize: 64))
                          .animate()
                          .scale(duration: 600.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 8),

                    Text(
                      winner.player.isEliminated
                          ? 'Everybody lost!'
                          : '${winner.player.name} wins!',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4E2C00),
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2),

                    if (!winner.player.isEliminated)
                      Text(
                        '${winner.player.cheeseScore} cheese holes collected!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.brown.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ).animate().fadeIn(delay: 500.ms),

                    const SizedBox(height: 24),

                    // Scoreboard
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withValues(alpha: 0.2),
                            blurRadius: 12,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              'Final Scores',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.brown.shade900,
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          ...rankings.asMap().entries.map((entry) {
                            final r = entry.value;
                            final isFirst = r.rank == 1 && !r.player.isEliminated;
                            return _ScoreRow(
                              rank: r.rank,
                              player: r.player,
                              isWinner: isFirst,
                            ).animate().fadeIn(
                                  delay: Duration(milliseconds: 600 + entry.key * 120),
                                );
                          }),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => const SetupScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF4E2C00), width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'New Game',
                              style: TextStyle(
                                color: Colors.brown.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final humanNames = game.players
                                  .where((p) => !p.isBot)
                                  .map((p) => p.name)
                                  .toList();
                              final hadBot = game.players.any((p) => p.isBot);
                              game.startGame(humanNames, vsBot: hadBot);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => const GameScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4E2C00),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Play Again',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.rank,
    required this.player,
    required this.isWinner,
  });
  final int rank;
  final Player player;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isWinner ? Colors.amber.shade50 : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Rank medal
          SizedBox(
            width: 32,
            child: Text(
              player.isEliminated
                  ? '💀'
                  : rank == 1
                      ? '🥇'
                      : rank == 2
                          ? '🥈'
                          : rank == 3
                              ? '🥉'
                              : '$rank.',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(
                fontWeight:
                    isWinner ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
                color: player.isEliminated
                    ? Colors.grey
                    : Colors.brown.shade900,
                decoration: player.isEliminated
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          // Trap count
          Text(
            '🪤 ${player.trapCount}',
            style: TextStyle(
              fontSize: 13,
              color: player.trapCount >= 3 ? Colors.red : Colors.brown.shade600,
            ),
          ),
          const SizedBox(width: 12),
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isWinner
                  ? Colors.amber.shade700
                  : Colors.brown.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '🧀 ${player.cheeseScore}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isWinner ? Colors.white : Colors.brown.shade800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
