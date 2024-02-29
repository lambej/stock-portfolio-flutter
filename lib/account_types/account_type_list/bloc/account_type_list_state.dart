part of 'account_type_list_bloc.dart';

enum AccountTypeListStatus { initial, loading, success, failure, maxReached }

final class AccountTypeListState extends Equatable {
  const AccountTypeListState({
    this.status = AccountTypeListStatus.initial,
    this.accountTypes = const [],
    this.lastDeletedAccountType,
  });

  final AccountTypeListStatus status;
  final List<AccountType> accountTypes;
  final AccountType? lastDeletedAccountType;
  AccountTypeListState copyWith({
    AccountTypeListStatus Function()? status,
    List<AccountType> Function()? accountTypes,
    AccountType? Function()? lastDeletedAccountType,
  }) {
    return AccountTypeListState(
      status: status != null ? status() : this.status,
      accountTypes: accountTypes != null ? accountTypes() : this.accountTypes,
      lastDeletedAccountType: lastDeletedAccountType != null
          ? lastDeletedAccountType()
          : this.lastDeletedAccountType,
    );
  }

  @override
  List<Object?> get props => [status, accountTypes, lastDeletedAccountType];
}
