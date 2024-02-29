// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountType _$AccountTypeFromJson(Map<String, dynamic> json) => AccountType(
      type: json['type'] as String,
      userId: json['userId'] as String,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$AccountTypeToJson(AccountType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'userId': instance.userId,
    };
