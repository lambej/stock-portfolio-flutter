// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contribution _$ContributionFromJson(Map<String, dynamic> json) => Contribution(
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      accountId: json['accountId'] as String,
      userId: json['userId'] as String,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$ContributionToJson(Contribution instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'accountId': instance.accountId,
      'userId': instance.userId,
    };
