part of 'add_position_bloc.dart';

enum AddPositionStatus { initial, loading, success, failure }

enum PositionAction { buy, sell }

extension AddPositionStatusX on AddPositionStatus {
  bool get isLoadingOrSuccess => [
        AddPositionStatus.loading,
        AddPositionStatus.success,
      ].contains(this);
}

class AddPositionState extends Equatable {
  const AddPositionState({
    this.status = AddPositionStatus.initial,
    this.initialPosition,
    this.ticker = '',
    this.qtyOfShares = 0,
    this.cost = 0,
    this.account,
    this.action = PositionAction.buy,
    this.currency = Currency.usd,
  });

  final AddPositionStatus status;
  final Position? initialPosition;
  final String ticker;
  final double qtyOfShares;
  final double cost;
  final Account? account;
  final PositionAction action;
  final Currency currency;

  bool get isNewPosition => initialPosition == null;

  AddPositionState copyWith({
    AddPositionStatus? status,
    Position? initialPosition,
    String? ticker,
    double? qtyOfShares,
    double? cost,
    Account? account,
    PositionAction? action,
    Currency? currency,
  }) {
    return AddPositionState(
      status: status ?? this.status,
      initialPosition: initialPosition ?? this.initialPosition,
      ticker: ticker ?? this.ticker,
      qtyOfShares: qtyOfShares ?? this.qtyOfShares,
      cost: cost ?? this.cost,
      account: account ?? this.account,
      action: action ?? this.action,
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object?> get props => [
        status,
        initialPosition,
        ticker,
        qtyOfShares,
        cost,
        account,
        action,
        currency
      ];
}

final class AddPositionMaxReached extends AddPositionState {}
