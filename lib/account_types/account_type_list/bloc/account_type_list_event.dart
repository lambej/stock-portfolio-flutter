part of 'account_type_list_bloc.dart';

@immutable
sealed class AccountTypeListEvent {}

final class AccountTypeSubscriptionRequested extends AccountTypeListEvent {
  AccountTypeSubscriptionRequested();
}

final class AccountTypeUndoDeletionRequested extends AccountTypeListEvent {
  AccountTypeUndoDeletionRequested();
}

final class AccountTypeDeleted extends AccountTypeListEvent {
  AccountTypeDeleted(this.accountType);

  final AccountType accountType;

  List<Object> get props => [accountType];
}
