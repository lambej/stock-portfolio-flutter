part of 'edit_account_type_bloc.dart';

sealed class EditAccountTypeEvent extends Equatable {
  const EditAccountTypeEvent();

  @override
  List<Object> get props => [];
}

final class EditAccountTypeTypeChanged extends EditAccountTypeEvent {
  const EditAccountTypeTypeChanged(this.type);

  final String type;

  @override
  List<Object> get props => [type];
}

final class EditAccountTypeSubmitted extends EditAccountTypeEvent {
  const EditAccountTypeSubmitted();
}
