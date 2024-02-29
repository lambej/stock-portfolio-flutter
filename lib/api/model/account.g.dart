// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      name: json['name'] as String,
      userId: json['userId'] as String,
      accountTypeId: json['accountTypeId'] as String? ?? '',
      id: json['id'] as String?,
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'accountTypeId': instance.accountTypeId,
      'userId': instance.userId,
    };
