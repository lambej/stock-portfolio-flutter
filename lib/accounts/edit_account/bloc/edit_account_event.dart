part of 'edit_account_bloc.dart';

sealed class EditAccountEvent extends Equatable {
  const EditAccountEvent();

  @override
  List<Object> get props => [];
}

final class EditAccountTypeChanged extends EditAccountEvent {
  const EditAccountTypeChanged(this.type);

  final AccountType type;

  @override
  List<Object> get props => [type];
}

final class EditAccountNameChanged extends EditAccountEvent {
  const EditAccountNameChanged(this.name);

  final String name;

  @override
  List<Object> get props => [name];
}

final class EditAccountDescriptionChanged extends EditAccountEvent {
  const EditAccountDescriptionChanged(this.description);

  final String description;

  @override
  List<Object> get props => [description];
}

final class EditAccountSubmitted extends EditAccountEvent {
  const EditAccountSubmitted();
}
