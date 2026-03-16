// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CheeseCard {
  String get id => throw _privateConstructorUsedError;
  int get holeCount =>
      throw _privateConstructorUsedError; // 1-6, shown on the back (visible in pantry)
  bool get isTrap => throw _privateConstructorUsedError;

  /// Create a copy of CheeseCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheeseCardCopyWith<CheeseCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheeseCardCopyWith<$Res> {
  factory $CheeseCardCopyWith(
          CheeseCard value, $Res Function(CheeseCard) then) =
      _$CheeseCardCopyWithImpl<$Res, CheeseCard>;
  @useResult
  $Res call({String id, int holeCount, bool isTrap});
}

/// @nodoc
class _$CheeseCardCopyWithImpl<$Res, $Val extends CheeseCard>
    implements $CheeseCardCopyWith<$Res> {
  _$CheeseCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheeseCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? holeCount = null,
    Object? isTrap = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      holeCount: null == holeCount
          ? _value.holeCount
          : holeCount // ignore: cast_nullable_to_non_nullable
              as int,
      isTrap: null == isTrap
          ? _value.isTrap
          : isTrap // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheeseCardImplCopyWith<$Res>
    implements $CheeseCardCopyWith<$Res> {
  factory _$$CheeseCardImplCopyWith(
          _$CheeseCardImpl value, $Res Function(_$CheeseCardImpl) then) =
      __$$CheeseCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, int holeCount, bool isTrap});
}

/// @nodoc
class __$$CheeseCardImplCopyWithImpl<$Res>
    extends _$CheeseCardCopyWithImpl<$Res, _$CheeseCardImpl>
    implements _$$CheeseCardImplCopyWith<$Res> {
  __$$CheeseCardImplCopyWithImpl(
      _$CheeseCardImpl _value, $Res Function(_$CheeseCardImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheeseCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? holeCount = null,
    Object? isTrap = null,
  }) {
    return _then(_$CheeseCardImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      holeCount: null == holeCount
          ? _value.holeCount
          : holeCount // ignore: cast_nullable_to_non_nullable
              as int,
      isTrap: null == isTrap
          ? _value.isTrap
          : isTrap // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$CheeseCardImpl implements _CheeseCard {
  const _$CheeseCardImpl(
      {required this.id, required this.holeCount, required this.isTrap});

  @override
  final String id;
  @override
  final int holeCount;
// 1-6, shown on the back (visible in pantry)
  @override
  final bool isTrap;

  @override
  String toString() {
    return 'CheeseCard(id: $id, holeCount: $holeCount, isTrap: $isTrap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheeseCardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.holeCount, holeCount) ||
                other.holeCount == holeCount) &&
            (identical(other.isTrap, isTrap) || other.isTrap == isTrap));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, holeCount, isTrap);

  /// Create a copy of CheeseCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheeseCardImplCopyWith<_$CheeseCardImpl> get copyWith =>
      __$$CheeseCardImplCopyWithImpl<_$CheeseCardImpl>(this, _$identity);
}

abstract class _CheeseCard implements CheeseCard {
  const factory _CheeseCard(
      {required final String id,
      required final int holeCount,
      required final bool isTrap}) = _$CheeseCardImpl;

  @override
  String get id;
  @override
  int get holeCount; // 1-6, shown on the back (visible in pantry)
  @override
  bool get isTrap;

  /// Create a copy of CheeseCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheeseCardImplCopyWith<_$CheeseCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
