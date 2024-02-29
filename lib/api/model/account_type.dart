// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:stock_portfolio/api/model/models.dart';
import 'package:uuid/uuid.dart';

part 'account_type.g.dart';

/// {@template account_type}
/// A single `account-type`.
///
/// Contains a [type]
/// flag.
///
/// If an [id] is provided, it cannot be empty. If no [id] is provided, one
/// will be generated.
///
/// [AccountType]s are immutable and can be copied using [copyWith], in addition
/// to being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class AccountType extends Equatable {
  /// {@macro todo_item}
  AccountType({
    required this.type,
    required this.userId,
    String? id,
  })  : assert(
          id == null || id.isNotEmpty,
          'id must either be null or not empty',
        ),
        id = id ?? const Uuid().v4();

  /// The unique identifier of the `account-type`.
  ///
  /// Cannot be empty.

  String id;

  /// The name of the `account`.
  ///
  /// Note that the type may be empty.
  final String type;

  /// The id of the `user` this `account-type` belongs to.
  ///
  /// Cannot be empty.
  final String userId;

  /// Returns a copy of this `account-type` with the given values updated.
  ///
  /// {@macro todo_item}
  AccountType copyWith({
    String? id,
    String? type,
    String? userId,
  }) {
    return AccountType(
      id: id ?? this.id,
      type: type ?? this.type,
      userId: userId ?? this.userId,
    );
  }

  /// Deserializes the given [JsonMap] into a [AccountType].
  static AccountType fromJson(JsonMap json, [String? id]) {
    final accountType = _$AccountTypeFromJson(json);

    if (id != null) {
      return accountType.copyWith(id: id);
    }
    return accountType;
  }

  /// Converts this [AccountType] into a [JsonMap].
  JsonMap toJson() => _$AccountTypeToJson(this);

  @override
  List<Object> get props => [id, type, userId];
}
