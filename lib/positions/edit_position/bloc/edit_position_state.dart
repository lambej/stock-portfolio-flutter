part of 'edit_position_bloc.dart';

enum EditPositionStatus { initial, loading, success, failure }

extension EditPositionStatusX on EditPositionStatus {
  bool get isLoadingOrSuccess => [
        EditPositionStatus.loading,
        EditPositionStatus.success,
      ].contains(this);
}

class EditPositionState extends Equatable {
  const EditPositionState({
    this.status = EditPositionStatus.initial,
    this.initialPosition,
    this.ticker = '',
    this.qtyOfShares = 0,
    this.cost = 0,
    this.account,
  });

  final EditPositionStatus status;
  final Position? initialPosition;
  final String ticker;
  final double qtyOfShares;
  final double cost;
  final Account? account;

  bool get isNewPosition => initialPosition == null;

  EditPositionState copyWith(
      {EditPositionStatus? status,
      Position? initialPosition,
      String? ticker,
      double? qtyOfShares,
      double? cost,
      Account? account}) {
    return EditPositionState(
        status: status ?? this.status,
        initialPosition: initialPosition ?? this.initialPosition,
        ticker: ticker ?? this.ticker,
        qtyOfShares: qtyOfShares ?? this.qtyOfShares,
        cost: cost ?? this.cost,
        account: account ?? this.account);
  }

  @override
  List<Object?> get props =>
      [status, initialPosition, ticker, qtyOfShares, cost];
}

final class EditPositionMaxReached extends EditPositionState {}
