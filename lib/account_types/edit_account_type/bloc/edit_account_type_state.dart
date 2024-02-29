part of 'edit_account_type_bloc.dart';

enum EditAccountTypeStatus { initial, loading, success, failure, maxReached }

extension EditAccountTypeStatusX on EditAccountTypeStatus {
  bool get isLoadingOrSuccess => [
        EditAccountTypeStatus.loading,
        EditAccountTypeStatus.success,
      ].contains(this);
}

final class EditAccountTypeState extends Equatable {
  const EditAccountTypeState({
    this.status = EditAccountTypeStatus.initial,
    this.initialAccountType,
    this.type = '',
  });

  final EditAccountTypeStatus status;
  final AccountType? initialAccountType;
  final String type;

  bool get isNewAccountType => initialAccountType == null;

  EditAccountTypeState copyWith({
    EditAccountTypeStatus? status,
    AccountType? initialAccountType,
    String? type,
  }) {
    return EditAccountTypeState(
      status: status ?? this.status,
      initialAccountType: initialAccountType ?? this.initialAccountType,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [status, initialAccountType, type];
}
