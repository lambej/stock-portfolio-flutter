part of 'position_transaction_list_bloc.dart';

enum PositionTransactionListStatus {
  initial,
  loading,
  success,
  failure,
  maxReached
}

@immutable
final class PositionTransactionListState extends Equatable {
  const PositionTransactionListState({
    this.status = PositionTransactionListStatus.initial,
    this.transactions = const [],
    this.lastDeletedTransaction,
    this.accounts = const [],
    this.accountsFilter = const [],
  });

  final PositionTransactionListStatus status;
  final List<Position> transactions;
  final Position? lastDeletedTransaction;
  final List<Account> accounts;
  final List<Account> accountsFilter;

  PositionTransactionListState copyWith({
    PositionTransactionListStatus Function()? status,
    List<Position> Function()? transactions,
    Position? Function()? lastDeletedTransaction,
    List<Account> Function()? accounts,
    List<Account> Function()? accountsFilter,
  }) {
    return PositionTransactionListState(
      status: status != null ? status() : this.status,
      transactions: transactions != null ? transactions() : this.transactions,
      lastDeletedTransaction: lastDeletedTransaction != null
          ? lastDeletedTransaction()
          : this.lastDeletedTransaction,
      accounts: accounts != null ? accounts() : this.accounts,
      accountsFilter:
          accountsFilter != null ? accountsFilter() : this.accountsFilter,
    );
  }

  @override
  List<Object?> get props => [
        status,
        transactions,
        lastDeletedTransaction,
        accounts,
        accountsFilter,
      ];
}
