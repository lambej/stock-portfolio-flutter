// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:stock_portfolio/api/model/models.dart';
import 'package:uuid/uuid.dart';

part 'balance.g.dart';

/// A single `balance`.
///
/// Contains an [amount], [date], [id] and [accountId]
///
/// If an [id] is provided, it cannot be empty. If no [id] is provided, one
/// will be generated.
///
/// [Balance]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.

@immutable
@JsonSerializable()
class Balance extends Equatable {
  /// {@macro balance_item}
  Balance({
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

  /// The unique identifier of the `balance`.
  ///
  /// Cannot be empty.
  String id;

  /// The amount of the `balance`.
  ///
  /// Defaults to 0
  final double amount;

  /// The date of the `balance`.
  ///
  /// Cannot be empty.
  final DateTime date;

  /// The id of the `account` this `balance` belongs to.
  ///
  /// Cannot be empty.
  final String accountId;

  /// The id of the `user` this `account` belongs to.
  ///
  /// Cannot be empty.
  final String userId;

  /// Returns a copy of this `balance` with the given values updated.
  Balance copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? accountId,
    String? userId,
  }) {
    return Balance(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      accountId: accountId ?? this.accountId,
      userId: userId ?? this.userId,
    );
  }

  /// Deserializes the given [JsonMap] into a [Balance].
  static Balance fromJson(JsonMap json, [String? id]) {
    final balance = _$BalanceFromJson(json);
    if (id != null) {
      return balance.copyWith(id: id);
    }
    return balance;
  }

  /// Converts this [Account] into a [JsonMap].
  JsonMap toJson() => _$BalanceToJson(this);

  @override
  List<Object> get props => [id, amount, date, accountId, userId];
}
