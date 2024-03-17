part of 'edit_position_bloc.dart';

sealed class EditPositionEvent extends Equatable {
  const EditPositionEvent();

  @override
  List<Object> get props => [];
}

final class EditPositionSubmitted extends EditPositionEvent {
  const EditPositionSubmitted();

  @override
  List<Object> get props => [];
}

final class EditPositionTickerChanged extends EditPositionEvent {
  const EditPositionTickerChanged({required this.ticker});

  final String ticker;

  @override
  List<Object> get props => [ticker];
}

final class EditPositionAccountChanged extends EditPositionEvent {
  const EditPositionAccountChanged({required this.account});

  final Account account;

  @override
  List<Object> get props => [account];
}

final class EditPositionQtyOfSharesChanged extends EditPositionEvent {
  const EditPositionQtyOfSharesChanged({required this.qtyOfShares});

  final double qtyOfShares;

  @override
  List<Object> get props => [qtyOfShares];
}
