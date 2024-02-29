part of 'account_list_bloc.dart';

enum AccountListStatus { initial, loading, success, failure }

final class AccountListState extends Equatable {
  const AccountListState({
    this.status = AccountListStatus.initial,
    this.accounts = const [],
    this.lastDeletedAccount,
  });

  final AccountListStatus status;
  final List<Account> accounts;
  final Account? lastDeletedAccount;

  AccountListState copyWith({
    AccountListStatus Function()? status,
    List<Account> Function()? accounts,
    Account? Function()? lastDeletedAccount,
  }) {
    return AccountListState(
      status: status != null ? status() : this.status,
      accounts: accounts != null ? accounts() : this.accounts,
      lastDeletedAccount: lastDeletedAccount != null
          ? lastDeletedAccount()
          : this.lastDeletedAccount,
    );
  }

  @override
  List<Object?> get props => [status, accounts, lastDeletedAccount];
}
