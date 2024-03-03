// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:stock_portfolio/api/model/models.dart';
import 'package:uuid/uuid.dart';

part 'position.g.dart';

/// A single `position`.
///
/// Contains a [ticker], [qtyOfShares], [cost], [currency], [accountId] and [id]
///
/// If an [id] is provided, it cannot be empty. If no [id] is provided, one
/// will be generated.
///
/// [Position]s are immutable and can be copied using [copyWith], in
///  addition to being serialized and deserialized using [toJson] and [fromJson]
/// respectively.

@immutable
@JsonSerializable()
class Position extends Equatable {
  /// {@macro position_item}
  Position({
    required this.ticker,
    required this.qtyOfShares,
    required this.cost,
    required this.currency,
    required this.accountId,
    required this.userId,
    String? id,
  })  : assert(
          id == null || id.isNotEmpty,
          'id must either be null or not empty',
        ),
        id = id ?? const Uuid().v4();

  /// The unique identifier of the `position`.
  ///
  /// Cannot be empty.
  String id;

  /// The ticker of the `position`.
  ///
  /// Cannot be empty.
  final String ticker;

  /// The quantity of shares of the `position`.
  ///
  /// Cannot be empty.
  final double qtyOfShares;

  /// The cost of the `position`.
  ///
  /// Cannot be empty.
  final double cost;

  /// The currency of the `position`.
  ///
  /// Cannot be empty.
  final String currency;

  /// The id of the `account` this `position` belongs to.
  ///
  /// Cannot be empty.
  final String accountId;

  /// The id of the `user` this `account` belongs to.
  ///
  /// Cannot be empty.
  final String userId;

  /// Returns a copy of this `position` with the given values updated.
  Position copyWith({
    String? id,
    String? ticker,
    double? qtyOfShares,
    double? cost,
    String? currency,
    String? accountId,
    String? userId,
  }) {
    return Position(
      id: id ?? this.id,
      ticker: ticker ?? this.ticker,
      qtyOfShares: qtyOfShares ?? this.qtyOfShares,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      accountId: accountId ?? this.accountId,
      userId: userId ?? this.userId,
    );
  }

  /// Deserializes the given [JsonMap] into a [position].
  static Position fromJson(JsonMap json, [String? id]) {
    final position = _$PositionFromJson(json);
    if (id != null) {
      return position.copyWith(id: id);
    }
    return position;
  }

  /// Converts this [Account] into a [JsonMap].
  JsonMap toJson() => _$PositionToJson(this);

  @override
  List<Object> get props =>
      [id, ticker, qtyOfShares, cost, currency, accountId, userId];
}
