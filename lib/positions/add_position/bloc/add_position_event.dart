part of 'add_position_bloc.dart';

sealed class AddPositionEvent extends Equatable {
  const AddPositionEvent();

  @override
  List<Object> get props => [];
}

final class AddPositionSubmitted extends AddPositionEvent {
  const AddPositionSubmitted();

  @override
  List<Object> get props => [];
}

final class AddPositionTickerChanged extends AddPositionEvent {
  const AddPositionTickerChanged({required this.ticker});

  final String ticker;

  @override
  List<Object> get props => [ticker];
}

final class AddPositionAccountChanged extends AddPositionEvent {
  const AddPositionAccountChanged({required this.account});

  final Account account;

  @override
  List<Object> get props => [account];
}

final class AddPositionQtyOfSharesChanged extends AddPositionEvent {
  const AddPositionQtyOfSharesChanged({required this.qtyOfShares});

  final double qtyOfShares;

  @override
  List<Object> get props => [qtyOfShares];
}

final class AddPositionCostChanged extends AddPositionEvent {
  const AddPositionCostChanged({required this.cost});

  final double cost;

  @override
  List<Object> get props => [cost];
}

final class AddPositionActionChanged extends AddPositionEvent {
  const AddPositionActionChanged({required this.action});

  final PositionAction action;

  @override
  List<Object> get props => [action];
}

final class AddPositionCurrencyChanged extends AddPositionEvent {
  const AddPositionCurrencyChanged({required this.currency});

  final Currency currency;

  @override
  List<Object> get props => [currency];
}
