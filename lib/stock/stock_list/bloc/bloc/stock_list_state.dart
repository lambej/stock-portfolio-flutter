part of 'stock_list_bloc.dart';

enum StockListStatus { initial, loading, success, failure }

final class StockListState extends Equatable {
  const StockListState({
    this.status = StockListStatus.initial,
    this.stockModel,
  });
  final StockListStatus status;
  final StockModel? stockModel;

  StockListState copyWith({
    StockListStatus? status,
    StockModel? stockModel,
  }) =>
      StockListState(
        status: status ?? this.status,
        stockModel: stockModel ?? this.stockModel,
      );

  @override
  List<Object?> get props => [
        status,
      ];
}
