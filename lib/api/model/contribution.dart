// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:stock_portfolio/api/model/models.dart';
import 'package:uuid/uuid.dart';

part 'contribution.g.dart';

/// A single `contribution`.
///
/// Contains an [amount], [date], [accountId] and [id]
///
/// If an [id] is provided, it cannot be empty. If no [id] is provided, one
/// will be generated.
///
/// [Contribution]s are immutable and can be copied using [copyWith], in
///  addition to being serialized and deserialized using [toJson] and [fromJson]
/// respectively.

@immutable
@JsonSerializable()
class Contribution extends Equatable {
  /// {@macro contribution_item}
  Contribution({
    required this.amount,
    required this.date,
    required this.accountId,
    required this.userId,
    String? id,
  })  : assert(
          id == null || id.isNotEmpty,
          'id must either be null or not empty',
        ),
        id = id ?? const Uuid().v4();

  /// The unique identifier of the `contribution`.
  ///
  /// Cannot be empty.
  String id;

  /// The amount of the `contribution`.
  /// A negative amount indicates a withdrawal.
  ///
  /// Defaults to 0
  final double amount;

  /// The date of the `contribution`.
  ///
  /// Cannot be empty.
  final DateTime date;

  /// The id of the `account` this `contribution` belongs to.
  ///
  /// Cannot be empty.
  final String accountId;

  /// The id of the `user` this `account` belongs to.
  ///
  /// Cannot be empty.
  final String userId;

  /// Returns the weighted amount of this `contribution` for the given
  /// [duration].
  double weightedAmount(int duration) {
    late int dayOfRange;
    final rangeType = duration > 31 ? _RangeType.year : _RangeType.month;
    switch (rangeType) {
      case _RangeType.month:
        dayOfRange = date.day;
      case _RangeType.year:
        final startOfYear = DateTime(date.year);
        dayOfRange = date.difference(startOfYear).inDays + 1;
    }
    return amount * ((duration - dayOfRange) / duration);
  }

  /// Returns a copy of this `contribution` with the given values updated.
  Contribution copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? accountId,
    String? userId,
  }) {
    return Contribution(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      accountId: accountId ?? this.accountId,
      userId: userId ?? this.userId,
    );
  }

  /// Deserializes the given [JsonMap] into a [Contribution].
  static Contribution fromJson(JsonMap json, [String? id]) {
    final contribution = _$ContributionFromJson(json);
    if (id != null) {
      return contribution.copyWith(id: id);
    }
    return contribution;
  }

  /// Converts this [Account] into a [JsonMap].
  JsonMap toJson() => _$ContributionToJson(this);

  @override
  List<Object> get props => [id, amount, date, accountId, userId];
}

enum _RangeType {
  month,
  year,
}
