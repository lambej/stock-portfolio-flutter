part of 'account_list_bloc.dart';

@immutable
sealed class AccountListEvent {}

final class AccountListSubscriptionRequested extends AccountListEvent {
  AccountListSubscriptionRequested();
}

final class AccountListUndoDeletionRequested extends AccountListEvent {
  AccountListUndoDeletionRequested();
}

final class AccountListDeleted extends AccountListEvent {
  AccountListDeleted(this.account);

  final Account account;

  List<Object> get props => [account];
}
