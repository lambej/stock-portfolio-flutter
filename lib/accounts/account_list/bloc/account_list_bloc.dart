import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';

part 'account_list_event.dart';
part 'account_list_state.dart';

class AccountListBloc extends Bloc<AccountListEvent, AccountListState> {
  AccountListBloc({
    required PortfolioRepository portfolioRepository,
  })  : _portfolioRepository = portfolioRepository,
        super(const AccountListState()) {
    on<AccountListSubscriptionRequested>(_onSubscriptionRequested);
    on<AccountListUndoDeletionRequested>(_onUndoDeletionRequested);
    on<AccountListDeleted>(_onAccountDeleted);
  }

  final PortfolioRepository _portfolioRepository;

  Future<void> _onSubscriptionRequested(
    AccountListSubscriptionRequested event,
    Emitter<AccountListState> emit,
  ) async {
    emit(state.copyWith(status: () => AccountListStatus.loading));

    await emit.forEach<List<Account>>(
      _portfolioRepository.getAccounts(),
      onData: (accounts) => state.copyWith(
        status: () => AccountListStatus.success,
        accounts: () => accounts,
      ),
      onError: (_, __) => state.copyWith(
        status: () => AccountListStatus.failure,
      ),
    );
  }

  Future<void> _onAccountDeleted(
    AccountListDeleted event,
    Emitter<AccountListState> emit,
  ) async {
    emit(state.copyWith(lastDeletedAccount: () => event.account));
    await _portfolioRepository.deleteAccount(event.account.id);
  }

  Future<void> _onUndoDeletionRequested(
    AccountListUndoDeletionRequested event,
    Emitter<AccountListState> emit,
  ) async {
    assert(
      state.lastDeletedAccount != null,
      'Last deleted account type can not be null.',
    );

    final account = state.lastDeletedAccount!;
    emit(state.copyWith(lastDeletedAccount: () => null));
    await _portfolioRepository.saveAccount(account);
  }
}
