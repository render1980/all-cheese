import 'package:freezed_annotation/freezed_annotation.dart';
import 'card_model.dart';

part 'player_model.freezed.dart';

@freezed
class Player with _$Player {
  const factory Player({
    required String id,
    required String name,
    @Default([]) List<CheeseCard> hand,
    @Default(false) bool isEliminated,
    @Default(false) bool isBot,
  }) = _Player;

  const Player._();

  int get trapCount => hand.where((c) => c.isTrap).length;
  int get cheeseScore => hand.where((c) => !c.isTrap).fold(0, (s, c) => s + c.holeCount);
  int get cheeseCardCount => hand.where((c) => !c.isTrap).length;
}
