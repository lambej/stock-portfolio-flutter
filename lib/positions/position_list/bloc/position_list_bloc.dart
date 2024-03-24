import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';
import 'package:stock_portfolio/stock/repository/finnhub_stock_repository.dart';

part 'position_list_event.dart';
part 'position_list_state.dart';

class PositionListBloc extends Bloc<PositionListEvent, PositionListState> {
  PositionListBloc({
    required PortfolioRepository portfolioRepository,
    required FinnhubRepository stockRepository,
  })  : _portfolioRepository = portfolioRepository,
        _stockRepository = stockRepository,
        super(PositionListInitial()) {
    on<PositionListEvent>((event, emit) {});

    on<LoadPositions>((event, emit) async {
      emit(PositionListLoading());

      final accounts = await _portfolioRepository.getAccounts().first;
      await emit.forEach<List<Position>>(
        _portfolioRepository.getPositions(accounts, _stockRepository),
        onData: PositionListLoaded.new,
        onError: (_, e) => PositionListError(e),
      );
    });
  }
  final PortfolioRepository _portfolioRepository;
  final FinnhubRepository _stockRepository;
}
