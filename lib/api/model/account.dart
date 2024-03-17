// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:stock_portfolio/api/model/models.dart';
import 'package:uuid/uuid.dart';

part 'account.g.dart';

/// {@template account_item}
/// A single `account` item.
///
/// Contains a [name], [description], [accountType] and [id]
/// flag.
///
/// If an [id] is provided, it cannot be empty. If no [id] is provided, one
/// will be generated.
///
/// [Account]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Account extends Equatable {
  /// {@macro account_item}
  Account({
    required this.name,
    required this.userId,
    this.accountTypeId = '',
    AccountType? accountType,
    String? id,
    this.description = '',
  })  : assert(
          id == null || id.isNotEmpty,
          'id must either be null or not empty',
        ),
        id = id ?? const Uuid().v4(),
        accountType = accountType ?? AccountType(type: '', userId: '');

  /// The unique identifier of the `account`.
  ///
  /// Cannot be empty.
  String id;

  /// The name of the `account`.
  ///
  /// Note that the name may be empty.
  final String name;

  /// The description of the `account`.
  ///
  /// Defaults to an empty string.
  final String description;

  /// The type of the `account`.
  ///
  /// Exclude from the json serialization.
  @JsonKey(includeFromJson: false)
  AccountType? accountType;

  /// The type of the `account`.
  ///
  /// Note that the type cannot be null.
  String accountTypeId;

  /// The id of the `user` this `account` belongs to.
  ///
  /// Cannot be empty.
  final String userId;

  /// Returns a copy of this `account` with the given values updated.
  ///
  /// {@macro todo_item}
  Account copyWith({
    String? id,
    String? name,
    String? description,
    AccountType? accountType,
    String? accountTypeId,
    String? userId,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      accountType: accountType ?? this.accountType,
      accountTypeId: accountTypeId ?? this.accountTypeId,
      userId: userId ?? this.userId,
    );
  }

  /// Deserializes the given [JsonMap] into a [Account].
  static Account fromJson(JsonMap json, [String? id]) {
    final account = _$AccountFromJson(json);
    if (id != null) {
      return account.copyWith(id: id);
    }
    return account;
  }

  /// Converts this [Account] into a [JsonMap].
  JsonMap toJson() => _$AccountToJson(this);

  @override
  List<Object> get props => [id, name, description, userId];
}
