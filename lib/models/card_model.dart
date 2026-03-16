import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_model.freezed.dart';

@freezed
class CheeseCard with _$CheeseCard {
  const factory CheeseCard({
    required String id,
    required int holeCount, // 1-6, shown on the back (visible in pantry)
    required bool isTrap,   // true = mousetrap, false = mouse+cheese (safe)
  }) = _CheeseCard;
}

/// Builds the full 36-card deck.
/// Distribution (total 18 traps / 18 cheese):
///   holes 1 → 1 trap, 5 cheese
///   holes 2 → 2 traps, 4 cheese
///   holes 3 → 3 traps, 3 cheese
///   holes 4 → 4 traps, 2 cheese
///   holes 5 → 5 traps, 1 cheese
///   holes 6 → 3 traps, 3 cheese  (high value but uncertain, makes 6 interesting)
List<CheeseCard> buildDeck() {
  final configs = <(int holes, int traps, int cheese)>[
    (1, 1, 5),
    (2, 2, 4),
    (3, 3, 3),
    (4, 4, 2),
    (5, 5, 1),
    (6, 3, 3),
  ];

  final deck = <CheeseCard>[];
  int idCounter = 0;

  for (final (holes, traps, cheese) in configs) {
    for (int i = 0; i < traps; i++) {
      deck.add(CheeseCard(
        id: 'card_${idCounter++}',
        holeCount: holes,
        isTrap: true,
      ));
    }
    for (int i = 0; i < cheese; i++) {
      deck.add(CheeseCard(
        id: 'card_${idCounter++}',
        holeCount: holes,
        isTrap: false,
      ));
    }
  }

  return deck;
}

/// Proper Fisher-Yates shuffle using dart:math Random.
List<CheeseCard> shuffleDeck(List<CheeseCard> deck) {
  final list = List<CheeseCard>.from(deck);
  final rng = Random();
  for (int i = list.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = list[i];
    list[i] = list[j];
    list[j] = tmp;
  }
  return list;
}
