part of 'position_transaction_list_bloc.dart';

sealed class PositionTransactionListEvent extends Equatable {
  const PositionTransactionListEvent();

  @override
  List<Object> get props => [];
}

final class LoadPositionTransactions extends PositionTransactionListEvent {
  const LoadPositionTransactions();

  @override
  List<Object> get props => [];
}

final class DeletePositionTransaction extends PositionTransactionListEvent {
  const DeletePositionTransaction(this.position);

  final Position position;

  @override
  List<Object> get props => [position];
}

final class UndoDeletePositionTransaction extends PositionTransactionListEvent {
  const UndoDeletePositionTransaction(this.transaction);

  final Position transaction;

  @override
  List<Object> get props => [transaction];
}

final class PositionTransactionListAccountsFilterChanged
    extends PositionTransactionListEvent {
  const PositionTransactionListAccountsFilterChanged(this.accountsFilter);

  final List<Account> accountsFilter;

  @override
  List<Object> get props => [accountsFilter];
}
