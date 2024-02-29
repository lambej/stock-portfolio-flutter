part of 'edit_account_bloc.dart';

enum EditAccountStatus { initial, loading, success, failure, maxReached }

extension EditAccountStatusX on EditAccountStatus {
  bool get isLoadingOrSuccess => [
        EditAccountStatus.loading,
        EditAccountStatus.success,
      ].contains(this);
}

final class EditAccountState extends Equatable {
  const EditAccountState({
    this.status = EditAccountStatus.initial,
    this.initialAccount,
    this.name = '',
    this.type,
    this.description = '',
  });

  final EditAccountStatus status;
  final Account? initialAccount;
  final String name;
  final AccountType? type;
  final String description;
  bool get isNewAccount => initialAccount == null;

  EditAccountState copyWith({
    EditAccountStatus? status,
    Account? initialAccount,
    String? name,
    AccountType? type,
    String? description,
  }) {
    return EditAccountState(
      status: status ?? this.status,
      initialAccount: initialAccount ?? this.initialAccount,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [status, initialAccount, name, type, description];
}
