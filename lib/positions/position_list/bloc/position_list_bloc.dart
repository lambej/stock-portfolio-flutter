import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
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
        super(const PositionListState()) {
    _setupEventHandlers();
  }

  final PortfolioRepository _portfolioRepository;
  final FinnhubRepository _stockRepository;

  void _setupEventHandlers() {
    on<LoadPositions>(_loadPositions);
    on<DeletePosition>(_deletePosition);
    on<UndoDeletePosition>(_undoDeletePosition);
    on<PositionListAccountsFilterChanged>(_onAccountsFilterChanged);
  }

  Future<void> _loadPositions(
    LoadPositions event,
    Emitter<PositionListState> emit,
  ) async {
    late var accountFilter = state.accountsFilter;
    final accounts = await _portfolioRepository.getAccounts().first;
    if (state.status == PositionListStatus.initial && accountFilter.isEmpty) {
      accountFilter = accounts;
    }
    emit(state.copyWith(status: () => PositionListStatus.loading));

    await emit.forEach<List<Position>>(
      _portfolioRepository.getPositions(accountFilter, _stockRepository),
      onData: (positions) => state.copyWith(
        status: () => PositionListStatus.success,
        positions: () => positions,
        accounts: accounts,
        accountsFilter: accountFilter,
      ),
      onError: (_, __) =>
          state.copyWith(status: () => PositionListStatus.failure),
    );
  }

  Future<void> _deletePosition(
    DeletePosition event,
    Emitter<PositionListState> emit,
  ) async {
    emit(
      state.copyWith(
        lastDeletedPosition: () => event.position,
      ),
    );

    try {
      // TODO: Should delete all positions with the same ticker within the account filter
      await _portfolioRepository.deletePosition(event.position.id);
    } catch (e) {
      state.positions.add(event.position);
      emit(
        state.copyWith(
          positions: () => state.positions,
          lastDeletedPosition: () => null,
        ),
      );
    }
  }

  Future<void> _undoDeletePosition(
    UndoDeletePosition event,
    Emitter<PositionListState> emit,
  ) async {
    assert(
      state.lastDeletedPosition != null,
      'Last deleted position can not be null.',
    );
    await _portfolioRepository.savePosition(event.position);
    emit(state.copyWith(lastDeletedPosition: () => null));
  }

  Future<void> _onAccountsFilterChanged(
    PositionListAccountsFilterChanged event,
    Emitter<PositionListState> emit,
  ) async {
    emit(state.copyWith(accountsFilter: event.accountsFilter));
  }
}
