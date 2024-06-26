// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:stock_portfolio/api/model/models.dart';
import 'package:stock_portfolio/stock/model/stock_model.dart';
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
    this.costBasis,
    this.currentPrice,
    String? id,
    this.account,
    this.totalShares,
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

  /// The `account` this `position` belongs to.
  ///
  /// Exclude from the json serialization.
  @JsonKey(includeFromJson: false)
  Account? account;

  /// The id of the `user` this `account` belongs to.
  ///
  /// Cannot be empty.
  final String userId;

  /// The cost basis of the `position`.
  @JsonKey(includeFromJson: false)
  final double? costBasis;

  /// The current price of the `position`.
  @JsonKey(includeFromJson: false)
  final double? currentPrice;

  /// The total shares of the `position`.
  @JsonKey(includeFromJson: false)
  final double? totalShares;

  /// Returns a copy of this `position` with the given values updated.
  Position copyWith({
    String? id,
    String? ticker,
    double? qtyOfShares,
    double? cost,
    String? currency,
    String? accountId,
    String? userId,
    double? costBasis,
    double? currentPrice,
    Account? account,
    double? totalShares,
  }) {
    return Position(
      id: id ?? this.id,
      ticker: ticker ?? this.ticker,
      qtyOfShares: qtyOfShares ?? this.qtyOfShares,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      accountId: accountId ?? this.accountId,
      userId: userId ?? this.userId,
      costBasis: costBasis ?? this.costBasis,
      currentPrice: currentPrice ?? this.currentPrice,
      account: account ?? this.account,
      totalShares: totalShares ?? this.totalShares,
    );
  }

  /// Deserializes the given [JsonMap] into a [Position].
  static Position fromJson(JsonMap json, [String? id]) {
    final position = _$PositionFromJson(json);
    if (id != null) {
      return position.copyWith(id: id);
    }
    return position;
  }

  /// Converts this [Account] into a [JsonMap].
  JsonMap toJson() => _$PositionToJson(this);

  /// Set Cost Basis of the `position`.
  Position setCostBasis(double cb) {
    return copyWith(costBasis: cb);
  }

  /// Set Total Shares of the `position`.
  Position setTotalShares(double ts) {
    return copyWith(totalShares: ts);
  }

  Position setStockInfo(StockModel stockInfo) {
    return copyWith(
      currentPrice: stockInfo.currentPrice,
    );
  }

  double get profit {
    if (costBasis != null && costBasis != 0) {
      return (currentPrice! - costBasis!) / costBasis! * 100;
    } else {
      return 0;
    }
  }

  double get marketValue => currentPrice! * qtyOfShares;

  @override
  List<Object?> get props =>
      [id, ticker, qtyOfShares, cost, currency, accountId, userId, account];
}
