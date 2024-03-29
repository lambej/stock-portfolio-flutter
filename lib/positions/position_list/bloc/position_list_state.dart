part of 'position_list_bloc.dart';

sealed class PositionListState extends Equatable {
  const PositionListState();

  @override
  List<Object> get props => [];
}

final class PositionListInitial extends PositionListState {}

final class PositionListLoading extends PositionListState {}

final class PositionListError extends PositionListState {
  const PositionListError(this.error);
  final Object error;

  @override
  List<Object> get props => [error];
}

final class PositionListLoaded extends PositionListState {
  const PositionListLoaded(this.positions);
  final List<Position> positions;

  @override
  List<Object> get props => [positions];
}
