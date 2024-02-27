import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stock_portfolio/stock/model/stock_model.dart';
import 'package:stock_portfolio/stock/repository/finnhub_stock_repository.dart';

part 'stock_list_event.dart';
part 'stock_list_state.dart';

class StockListBloc extends Bloc<StockListEvent, StockListState> {
  StockListBloc({required FinnhubRepository stockRepository})
      : _stockRepository = stockRepository,
        super(const StockListState()) {
    on<StockListEvent>((event, emit) {});
    on<StockListRequested>(_onStockListRequested);
  }
  final FinnhubRepository _stockRepository;

  Future<void> _onStockListRequested(
    StockListRequested event,
    Emitter<StockListState> emit,
  ) async {
    emit(
      state.copyWith(
        status: StockListStatus.loading,
      ),
    );

    try {
      final stockModel =
          await _stockRepository.fetchStockInformation(event.tickerSymbol);
      emit(
        state.copyWith(
          status: StockListStatus.success,
          stockModel: stockModel,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StockListStatus.failure,
        ),
      );
    }
  }
}
