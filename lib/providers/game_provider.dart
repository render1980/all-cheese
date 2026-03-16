import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/card_model.dart';
import '../models/player_model.dart';

enum GamePhase {
  rolling,       // Current player needs to roll the dice
  peek,          // No match: player selects any card to peek
  peeking,       // Card front is temporarily revealed
  matchAction,   // Match found: choose Take or Remove
  selectTake,    // Select which matching card to take
  selectRemove,  // Select which matching card to remove
  gameOver,
}

class GameProvider extends ChangeNotifier {
  // ── Game state ──────────────────────────────────────────────────────────
  List<Player> players = [];
  List<CheeseCard> pantry = [];    // 6 visible pantry slots
  List<CheeseCard> reserve = [];   // draw pile
  List<CheeseCard> discard = [];   // discard pile

  int currentPlayerIndex = 0;
  int? diceValue;
  GamePhase phase = GamePhase.rolling;

  /// Index of pantry card currently peeked at (-1 = none).
  int peekingIndex = -1;

  /// Indices in pantry that match the current dice roll.
  List<int> matchingIndices = [];

  String statusMessage = '';

  // Animation flags listened to by UI
  bool isDiceRolling = false;

  // ── Bot state ────────────────────────────────────────────────────────────
  /// Maps card ID → isTrap, accumulated from bot's own peeks.
  final Map<String, bool> _botMemory = {};
  final Random _rng = Random();

  // ── Public API ──────────────────────────────────────────────────────────

  /// [humanNames] are the human players.
  /// When [vsBot] is true a bot player named "Bot 🤖" is appended.
  void startGame(List<String> humanNames, {bool vsBot = false}) {
    players = [
      for (int i = 0; i < humanNames.length; i++)
        Player(id: 'p$i', name: humanNames[i]),
      if (vsBot)
        const Player(id: 'bot', name: 'Bot 🤖', isBot: true),
    ];

    final deck = shuffleDeck(buildDeck());
    pantry = deck.take(6).toList();
    reserve = deck.skip(6).toList();
    discard = [];

    currentPlayerIndex = 0;
    diceValue = null;
    peekingIndex = -1;
    matchingIndices = [];
    _botMemory.clear();
    phase = GamePhase.rolling;
    _updateStatus();
    notifyListeners();

    if (currentPlayer.isBot) _scheduleBotTurn();
  }

  /// Roll the dice (1–6). After result is known, bot continues automatically.
  void rollDice() {
    if (phase != GamePhase.rolling) return;

    isDiceRolling = true;
    notifyListeners();

    Timer(const Duration(milliseconds: 600), () {
      diceValue = _rng.nextInt(6) + 1;
      isDiceRolling = false;

      matchingIndices = [
        for (int i = 0; i < pantry.length; i++)
          if (pantry[i].holeCount == diceValue) i,
      ];

      if (matchingIndices.isEmpty) {
        phase = GamePhase.peek;
      } else {
        phase = GamePhase.matchAction;
      }

      _updateStatus();
      notifyListeners();

      if (currentPlayer.isBot) _botHandleAfterRoll();
    });
  }

  /// Peek at a card when there is no match.
  /// Bot automatically stores the result in its memory.
  void peekCard(int pantryIndex) {
    if (phase != GamePhase.peek) return;

    if (currentPlayer.isBot) {
      // Bot remembers what it saw
      final card = pantry[pantryIndex];
      _botMemory[card.id] = card.isTrap;
    }

    peekingIndex = pantryIndex;
    phase = GamePhase.peeking;
    _updateStatus();
    notifyListeners();

    // Bot peeks for a shorter time so the human can follow along
    final duration = currentPlayer.isBot
        ? const Duration(milliseconds: 1800)
        : const Duration(seconds: 3);

    Timer(duration, () {
      peekingIndex = -1;
      _endTurn();
    });
  }

  /// Choose "take" (true) or "remove" (false) when a match is found.
  /// If only one card matches, it is picked automatically.
  void chooseAction(bool take) {
    if (phase != GamePhase.matchAction) return;
    if (matchingIndices.length == 1) {
      phase = take ? GamePhase.selectTake : GamePhase.selectRemove;
      if (take) {
        takeCard(matchingIndices.first);
      } else {
        removeCard(matchingIndices.first);
      }
      return;
    }
    phase = take ? GamePhase.selectTake : GamePhase.selectRemove;
    _updateStatus();
    notifyListeners();
  }

  /// Take a matching card from the pantry into the current player's hand.
  void takeCard(int pantryIndex) {
    if (phase != GamePhase.selectTake) return;
    if (!matchingIndices.contains(pantryIndex)) return;

    final card = pantry[pantryIndex];
    pantry.removeAt(pantryIndex);
    // Card is now in hand – no longer in pantry, remove from memory
    _botMemory.remove(card.id);

    final player = players[currentPlayerIndex];
    final updatedPlayer = player.copyWith(hand: [...player.hand, card]);
    players = [
      for (int i = 0; i < players.length; i++)
        if (i == currentPlayerIndex) updatedPlayer else players[i],
    ];

    _refillPantry();

    // Check if player just got their 3rd trap → eliminated
    if (updatedPlayer.trapCount >= 3) {
      players = [
        for (int i = 0; i < players.length; i++)
          if (i == currentPlayerIndex)
            updatedPlayer.copyWith(isEliminated: true)
          else
            players[i],
      ];
      _triggerGameOver();
      return;
    }

    _endTurn();
  }

  /// Remove a matching card from the pantry to discard.
  void removeCard(int pantryIndex) {
    if (phase != GamePhase.selectRemove) return;
    if (!matchingIndices.contains(pantryIndex)) return;

    final card = pantry[pantryIndex];
    pantry.removeAt(pantryIndex);
    discard.add(card);
    _botMemory.remove(card.id);

    _refillPantry();
    _endTurn();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  void _refillPantry() {
    while (pantry.length < 6 && reserve.isNotEmpty) {
      pantry.add(reserve.removeLast());
    }
  }

  void _endTurn() {
    // 2–3 player rule (counting bot as a player): additional card removed per turn
    if (players.length <= 3 && reserve.isNotEmpty) {
      discard.add(reserve.removeLast());
    }

    if (reserve.isEmpty) {
      _triggerGameOver();
      return;
    }

    _advancePlayer();

    diceValue = null;
    peekingIndex = -1;
    matchingIndices = [];
    phase = GamePhase.rolling;
    _updateStatus();
    notifyListeners();

    if (currentPlayer.isBot) _scheduleBotTurn();
  }

  void _advancePlayer() {
    final active = players.where((p) => !p.isEliminated).toList();
    if (active.length <= 1) return;

    int next = (currentPlayerIndex + 1) % players.length;
    while (players[next].isEliminated) {
      next = (next + 1) % players.length;
    }
    currentPlayerIndex = next;
  }

  void _triggerGameOver() {
    phase = GamePhase.gameOver;
    _updateStatus();
    notifyListeners();
  }

  void _updateStatus() {
    if (players.isEmpty) return;
    final name = players[currentPlayerIndex].name;
    final isBot = players[currentPlayerIndex].isBot;
    switch (phase) {
      case GamePhase.rolling:
        statusMessage = isBot ? '🤖 $name is rolling...' : '$name: tap the dice to roll!';
      case GamePhase.peek:
        statusMessage = isBot
            ? '🤖 $name is choosing a card to peek at...'
            : '$name: no match — pick any card to peek at its front';
      case GamePhase.peeking:
        statusMessage = isBot ? '🤖 $name is peeking...' : '$name: remember this card!';
      case GamePhase.matchAction:
        statusMessage = isBot
            ? '🤖 $name is deciding what to do ($diceValue holes)...'
            : '$name: match found ($diceValue holes)! Take it or Remove it?';
      case GamePhase.selectTake:
        statusMessage = isBot
            ? '🤖 $name is picking a card to take...'
            : '$name: pick a $diceValue-hole card to take';
      case GamePhase.selectRemove:
        statusMessage = isBot
            ? '🤖 $name is picking a card to remove...'
            : '$name: pick a $diceValue-hole card to remove';
      case GamePhase.gameOver:
        statusMessage = 'Game over! Count those cheese holes!';
    }
  }

  // ── Bot AI ───────────────────────────────────────────────────────────────

  /// Trigger the bot to roll after a natural pause.
  void _scheduleBotTurn() {
    Timer(const Duration(milliseconds: 900), () {
      if (phase == GamePhase.rolling && currentPlayer.isBot) rollDice();
    });
  }

  /// Called right after the dice result is set when it's the bot's turn.
  void _botHandleAfterRoll() {
    if (matchingIndices.isEmpty) {
      // No match — peek a card
      Timer(const Duration(milliseconds: 500), () {
        if (phase == GamePhase.peek && currentPlayer.isBot) {
          peekCard(_botChoosePeekIndex());
        }
      });
    } else {
      // Match — decide to take or remove, then select the card
      Timer(const Duration(milliseconds: 700), () {
        if (phase != GamePhase.matchAction || !currentPlayer.isBot) return;
        final shouldTake = _botDecideTake();
        chooseAction(shouldTake);
        // If multiple matches, we are now in selectTake/selectRemove
        if (phase == GamePhase.selectTake || phase == GamePhase.selectRemove) {
          Timer(const Duration(milliseconds: 450), () {
            if (currentPlayer.isBot) _botSelectCard();
          });
        }
        // If only one match, chooseAction auto-picked and _endTurn already ran.
      });
    }
  }

  /// Bot picks the pantry card to peek at — prefers unseen cards.
  int _botChoosePeekIndex() {
    final unknown = [
      for (int i = 0; i < pantry.length; i++)
        if (!_botMemory.containsKey(pantry[i].id)) i,
    ];
    if (unknown.isNotEmpty) return unknown[_rng.nextInt(unknown.length)];
    return _rng.nextInt(pantry.length);
  }

  /// Bot decides whether to take or remove a matching card.
  bool _botDecideTake() {
    final allTraps = matchingIndices.every((i) {
      final id = pantry[i].id;
      return _botMemory.containsKey(id) && _botMemory[id] == true;
    });
    if (allTraps) return false; // remove — all known traps

    final hasKnownCheese = matchingIndices.any((i) {
      final id = pantry[i].id;
      return _botMemory.containsKey(id) && _botMemory[id] == false;
    });
    if (hasKnownCheese) return true; // take — known cheese available

    // Unknown: slightly aggressive, prefer taking
    return _rng.nextDouble() < 0.65;
  }

  /// Bot selects which specific card to take or remove.
  void _botSelectCard() {
    if (phase == GamePhase.selectTake) {
      // Prefer known cheese; fall back to random
      final knownCheese = matchingIndices.where((i) {
        final id = pantry[i].id;
        return _botMemory.containsKey(id) && _botMemory[id] == false;
      }).toList();
      final idx = knownCheese.isNotEmpty
          ? knownCheese[_rng.nextInt(knownCheese.length)]
          : matchingIndices[_rng.nextInt(matchingIndices.length)];
      takeCard(idx);
    } else if (phase == GamePhase.selectRemove) {
      // Prefer known traps; fall back to random
      final knownTraps = matchingIndices.where((i) {
        final id = pantry[i].id;
        return _botMemory.containsKey(id) && _botMemory[id] == true;
      }).toList();
      final idx = knownTraps.isNotEmpty
          ? knownTraps[_rng.nextInt(knownTraps.length)]
          : matchingIndices[_rng.nextInt(matchingIndices.length)];
      removeCard(idx);
    }
  }

  // ── Score helpers ────────────────────────────────────────────────────────

  List<({Player player, int rank})> get rankings {
    final sorted = [...players]
      ..sort((a, b) {
        if (a.isEliminated != b.isEliminated) return a.isEliminated ? 1 : -1;
        if (b.cheeseScore != a.cheeseScore) {
          return b.cheeseScore.compareTo(a.cheeseScore);
        }
        return b.cheeseCardCount.compareTo(a.cheeseCardCount);
      });

    int rank = 1;
    return [
      for (int i = 0; i < sorted.length; i++)
        (
          player: sorted[i],
          rank: sorted[i].isEliminated
              ? sorted.length
              : (i > 0 &&
                      sorted[i].cheeseScore == sorted[i - 1].cheeseScore &&
                      sorted[i].cheeseCardCount == sorted[i - 1].cheeseCardCount
                  ? rank
                  : (rank = i + 1)),
        )
    ];
  }

  Player get currentPlayer => players[currentPlayerIndex];

  bool get isBotTurn =>
      players.isNotEmpty && players[currentPlayerIndex].isBot;
}
