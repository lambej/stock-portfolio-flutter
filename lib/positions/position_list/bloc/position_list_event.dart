part of 'position_list_bloc.dart';

sealed class PositionListEvent extends Equatable {
  const PositionListEvent();

  @override
  List<Object> get props => [];
}

final class LoadPositions extends PositionListEvent {
  const LoadPositions();

  @override
  List<Object> get props => [];
}

final class DeletePosition extends PositionListEvent {
  const DeletePosition(this.position);

  final Position position;

  @override
  List<Object> get props => [position];
}

final class UndoDeletePosition extends PositionListEvent {
  const UndoDeletePosition(this.position);

  final Position position;

  @override
  List<Object> get props => [position];
}
