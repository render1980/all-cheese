import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/player_model.dart';
import '../providers/game_provider.dart';
import '../widgets/cheese_card_widget.dart';
import '../widgets/dice_widget.dart';
import 'game_over_screen.dart';
import 'setup_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    if (game.phase == GamePhase.gameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GameOverScreen()),
        );
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE082), Color(0xFFFFC107)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(game: game),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _PilesRow(game: game),
                      const SizedBox(height: 16),
                      _PantrySection(game: game),
                      const SizedBox(height: 12),
                      _StatusBanner(game: game),
                      const SizedBox(height: 12),
                      _ActionRow(game: game),
                      const SizedBox(height: 16),
                      _AllPlayersHands(game: game),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.game});
  final GameProvider game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF5D3A00),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Row(
        children: [
          const Text('🧀', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          const Text(
            'All Cheese',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          if (game.players.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${game.currentPlayer.name}\'s turn',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _confirmQuit(context),
            icon: const Icon(Icons.exit_to_app, color: Colors.white70),
            tooltip: 'Quit',
          ),
        ],
      ),
    );
  }

  void _confirmQuit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quit game?'),
        content: const Text('Current progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SetupScreen()),
              );
            },
            child: const Text('Quit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Piles row (reserve + discard) ────────────────────────────────────────────

class _PilesRow extends StatelessWidget {
  const _PilesRow({required this.game});
  final GameProvider game;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PileLabel(
          label: 'Reserve',
          count: game.reserve.length,
          child: game.reserve.isEmpty
              ? const FaceDownCardWidget(opacity: 0.3)
              : Stack(
                  children: [
                    if (game.reserve.length > 2)
                      const Positioned(
                        left: 4,
                        top: 4,
                        child: FaceDownCardWidget(),
                      ),
                    if (game.reserve.length > 1)
                      const Positioned(
                        left: 2,
                        top: 2,
                        child: FaceDownCardWidget(),
                      ),
                    const FaceDownCardWidget(),
                  ],
                ),
        ),
        const SizedBox(width: 32),
        _PileLabel(
          label: 'Discard',
          count: game.discard.length,
          child: game.discard.isEmpty
              ? const FaceDownCardWidget(opacity: 0.3, width: 72, height: 104)
              : CheeseCardWidget(
                  card: game.discard.last,
                  showFront: true,
                  width: 72,
                  height: 104,
                ),
        ),
      ],
    );
  }
}

class _PileLabel extends StatelessWidget {
  const _PileLabel({
    required this.label,
    required this.count,
    required this.child,
  });
  final String label;
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade800,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(width: 80, height: 110, child: child),
      ],
    );
  }
}

// ── Pantry ───────────────────────────────────────────────────────────────────

class _PantrySection extends StatelessWidget {
  const _PantrySection({required this.game});
  final GameProvider game;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '— Pantry —',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.brown.shade900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (int i = 0; i < game.pantry.length; i++)
              _PantryCard(game: game, index: i),
          ],
        ),
      ],
    );
  }
}

class _PantryCard extends StatelessWidget {
  const _PantryCard({required this.game, required this.index});
  final GameProvider game;
  final int index;

  @override
  Widget build(BuildContext context) {
    final card = game.pantry[index];
    final isPeeking =
        game.phase == GamePhase.peeking && game.peekingIndex == index;
    final isMatch = game.matchingIndices.contains(index);

    // Cards are never selectable during the bot's turn
    final isSelectablePeek = !game.isBotTurn && game.phase == GamePhase.peek;
    final isSelectableTake =
        !game.isBotTurn && game.phase == GamePhase.selectTake && isMatch;
    final isSelectableRemove =
        !game.isBotTurn && game.phase == GamePhase.selectRemove && isMatch;

    final isSelectable = isSelectablePeek || isSelectableTake || isSelectableRemove;

    VoidCallback? onTap;
    if (isSelectablePeek) {
      onTap = () => context.read<GameProvider>().peekCard(index);
    } else if (isSelectableTake) {
      onTap = () => context.read<GameProvider>().takeCard(index);
    } else if (isSelectableRemove) {
      onTap = () => context.read<GameProvider>().removeCard(index);
    }

    return CheeseCardWidget(
      card: card,
      showFront: isPeeking,
      isSelectable: isSelectable,
      isHighlighted: isMatch &&
          (game.phase == GamePhase.matchAction ||
              game.phase == GamePhase.selectTake ||
              game.phase == GamePhase.selectRemove),
      onTap: onTap,
    ).animate(key: ValueKey('pantry_$index')).fadeIn(duration: 300.ms);
  }
}

// ── Status banner ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.game});
  final GameProvider game;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(game.statusMessage),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF5D3A00).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          game.statusMessage,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ── Action row (dice + buttons) ──────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.game});
  final GameProvider game;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DiceWidget(
          value: game.diceValue,
          isRolling: game.isDiceRolling,
          enabled: game.phase == GamePhase.rolling && !game.isBotTurn,
          onTap: () => context.read<GameProvider>().rollDice(),
        ),
        const SizedBox(width: 20),
        if (game.isBotTurn) ...[
          _BotThinkingBadge(),
        ] else if (game.phase == GamePhase.matchAction) ...[
          _ActionButton(
            label: 'Take it 🐭',
            color: const Color(0xFF2E7D32),
            onPressed: () => context.read<GameProvider>().chooseAction(true),
          ),
          const SizedBox(width: 10),
          _ActionButton(
            label: 'Remove 🗑️',
            color: const Color(0xFFC62828),
            onPressed: () => context.read<GameProvider>().chooseAction(false),
          ),
        ] else if (game.phase == GamePhase.peek ||
            game.phase == GamePhase.selectTake ||
            game.phase == GamePhase.selectRemove ||
            game.phase == GamePhase.peeking) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.brown.shade700.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              game.phase == GamePhase.peek
                  ? '← Tap any pantry card to peek'
                  : game.phase == GamePhase.peeking
                      ? '⏳ Remember...'
                      : game.phase == GamePhase.selectTake
                          ? '← Tap a highlighted card to take'
                          : '← Tap a highlighted card to remove',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }
}

class _BotThinkingBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.brown.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          ),
          SizedBox(width: 10),
          Text(
            '🤖 Bot is thinking...',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    ).animate().scale(duration: 200.ms, curve: Curves.elasticOut);
  }
}

// ── Player hands ─────────────────────────────────────────────────────────────

class _AllPlayersHands extends StatelessWidget {
  const _AllPlayersHands({required this.game});
  final GameProvider game;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '— Player Hands —',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.brown.shade900,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ...game.players.map((player) => _PlayerHandRow(
              player: player,
              isCurrentPlayer:
                  game.players.indexOf(player) == game.currentPlayerIndex,
            )),
      ],
    );
  }
}

class _PlayerHandRow extends StatelessWidget {
  const _PlayerHandRow({
    required this.player,
    required this.isCurrentPlayer,
  });
  final Player player;
  final bool isCurrentPlayer;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? Colors.white.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer ? Colors.amber.shade700 : Colors.transparent,
          width: 2,
        ),
        boxShadow: isCurrentPlayer
            ? [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.4),
                  blurRadius: 8,
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          // Name + trap count
          SizedBox(
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (player.isEliminated)
                      const Text('💀', style: TextStyle(fontSize: 14))
                    else if (isCurrentPlayer)
                      const Text('▶', style: TextStyle(fontSize: 12))
                    else
                      const SizedBox(width: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        player.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: player.isEliminated
                              ? Colors.grey
                              : Colors.brown.shade900,
                          decoration: player.isEliminated
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text('🧀', style: TextStyle(fontSize: 11)),
                    Text(
                      ' ${player.cheeseScore}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.brown.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('🪤', style: TextStyle(fontSize: 11)),
                    Text(
                      ' ${player.trapCount}/3',
                      style: TextStyle(
                        fontSize: 12,
                        color: player.trapCount >= 2
                            ? Colors.red.shade700
                            : Colors.brown.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Cards in hand
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (player.hand.isEmpty)
                    Text(
                      'No cards yet',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.brown.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ...player.hand.map((card) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: CheeseCardWidget(
                            card: card,
                            showFront: true,
                            width: 52,
                            height: 72,
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
