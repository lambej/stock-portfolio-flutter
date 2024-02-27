part of 'stock_list_bloc.dart';

sealed class StockListEvent extends Equatable {
  const StockListEvent();

  @override
  List<Object> get props => [];
}

class StockListRequested extends StockListEvent {
  const StockListRequested(this.tickerSymbol);

  final String tickerSymbol;

  @override
  List<Object> get props => [tickerSymbol];
}

class StockInfoRefreshRequested extends StockListEvent {
  const StockInfoRefreshRequested(this.tickerSymbol);

  final String tickerSymbol;

  @override
  List<Object> get props => [tickerSymbol];
}
