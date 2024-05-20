import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';

part 'position_transaction_list_event.dart';
part 'position_transaction_list_state.dart';

class PositionTransactionListBloc
    extends Bloc<PositionTransactionListEvent, PositionTransactionListState> {
  PositionTransactionListBloc({
    required PortfolioRepository portfolioRepository,
  })  : _portfolioRepository = portfolioRepository,
        super(const PositionTransactionListState()) {
    _setupEventHandlers();
  }

  final PortfolioRepository _portfolioRepository;

  void _setupEventHandlers() {
    on<LoadPositionTransactions>(_loadPositionTransactions);
    on<DeletePositionTransaction>(_deletePositionTransaction);
    on<UndoDeletePositionTransaction>(_undoDeletePositionTransaction);
    on<PositionTransactionListAccountsFilterChanged>(_onAccountsFilterChanged);
  }

  Future<void> _loadPositionTransactions(
    LoadPositionTransactions event,
    Emitter<PositionTransactionListState> emit,
  ) async {
    late var accountFilter = state.accountsFilter;
    final accounts = await _portfolioRepository.getAccounts().first;
    if (state.status == PositionTransactionListStatus.initial &&
        accountFilter.isEmpty) {
      accountFilter = accounts;
    }
    emit(state.copyWith(status: () => PositionTransactionListStatus.loading));

    await emit.forEach<List<Position>>(
      _portfolioRepository.getPositionTransactions(accountFilter),
      onData: (positions) => state.copyWith(
        status: () => PositionTransactionListStatus.success,
        transactions: () => positions,
        accounts: () => accounts,
        accountsFilter: () => accountFilter,
      ),
      onError: (_, __) =>
          state.copyWith(status: () => PositionTransactionListStatus.failure),
    );
  }

  Future<void> _deletePositionTransaction(
    DeletePositionTransaction event,
    Emitter<PositionTransactionListState> emit,
  ) async {
    emit(
      state.copyWith(
        lastDeletedTransaction: () => event.position,
      ),
    );

    try {
      await _portfolioRepository.deletePosition(event.position.id);
    } catch (e) {
      state.transactions.add(event.position);
      emit(
        state.copyWith(
          transactions: () => state.transactions,
          lastDeletedTransaction: () => null,
        ),
      );
    }
  }

  Future<void> _undoDeletePositionTransaction(
    UndoDeletePositionTransaction event,
    Emitter<PositionTransactionListState> emit,
  ) async {
    assert(
      state.lastDeletedTransaction != null,
      'Last deleted position can not be null.',
    );
    await _portfolioRepository.savePosition(event.transaction);
    emit(state.copyWith(lastDeletedTransaction: () => null));
  }

  Future<void> _onAccountsFilterChanged(
    PositionTransactionListAccountsFilterChanged event,
    Emitter<PositionTransactionListState> emit,
  ) async {
    emit(state.copyWith(accountsFilter: () => state.accountsFilter));
  }
}
