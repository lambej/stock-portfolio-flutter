// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Position _$PositionFromJson(Map<String, dynamic> json) => Position(
      ticker: json['ticker'] as String,
      qtyOfShares: (json['qtyOfShares'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      currency: json['currency'] as String,
      accountId: json['accountId'] as String,
      userId: json['userId'] as String,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
      'id': instance.id,
      'ticker': instance.ticker,
      'qtyOfShares': instance.qtyOfShares,
      'cost': instance.cost,
      'currency': instance.currency,
      'accountId': instance.accountId,
      'userId': instance.userId,
    };
