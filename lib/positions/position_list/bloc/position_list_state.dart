part of 'position_list_bloc.dart';

enum PositionListStatus { initial, loading, success, failure, maxReached }

@immutable
final class PositionListState extends Equatable {
  const PositionListState({
    this.status = PositionListStatus.initial,
    this.positions = const [],
    this.lastDeletedPosition,
    this.accounts = const [],
    this.accountsFilter = const [],
  });
  final PositionListStatus status;
  final List<Position> positions;
  final Position? lastDeletedPosition;
  final List<Account> accounts;
  final List<Account> accountsFilter;

  PositionListState copyWith({
    PositionListStatus Function()? status,
    List<Position> Function()? positions,
    Position? Function()? lastDeletedPosition,
    List<Account>? accounts,
    List<Account>? accountsFilter,
  }) {
    return PositionListState(
      status: status != null ? status() : this.status,
      positions: positions != null ? positions() : this.positions,
      lastDeletedPosition: lastDeletedPosition != null
          ? lastDeletedPosition()
          : this.lastDeletedPosition,
      accounts: accounts ?? this.accounts,
      accountsFilter: accountsFilter ?? this.accountsFilter,
    );
  }

  @override
  List<Object?> get props =>
      [status, positions, lastDeletedPosition, accounts, accountsFilter];
}
