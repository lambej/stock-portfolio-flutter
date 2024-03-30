part of 'position_list_bloc.dart';

enum PositionListStatus { initial, loading, success, failure, maxReached }

final class PositionListState extends Equatable {
  const PositionListState({
    this.status = PositionListStatus.initial,
    this.positions = const [],
    this.lastDeletedPosition,
  });
  final PositionListStatus status;
  final List<Position> positions;
  final Position? lastDeletedPosition;

  PositionListState copyWith({
    PositionListStatus Function()? status,
    List<Position> Function()? positions,
    Position? Function()? lastDeletedPosition,
  }) {
    return PositionListState(
      status: status != null ? status() : this.status,
      positions: positions != null ? positions() : this.positions,
      lastDeletedPosition: lastDeletedPosition != null
          ? lastDeletedPosition()
          : this.lastDeletedPosition,
    );
  }

  @override
  List<Object?> get props => [status, positions, lastDeletedPosition];
}
