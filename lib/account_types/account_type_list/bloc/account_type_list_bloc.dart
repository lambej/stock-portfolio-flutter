import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';

part 'account_type_list_event.dart';
part 'account_type_list_state.dart';

class AccountTypeListBloc
    extends Bloc<AccountTypeListEvent, AccountTypeListState> {
  AccountTypeListBloc({
    required PortfolioRepository portfolioRepository,
  })  : _portfolioRepository = portfolioRepository,
        super(const AccountTypeListState()) {
    on<AccountTypeSubscriptionRequested>(_onSubscriptionRequested);
    on<AccountTypeUndoDeletionRequested>(_onUndoDeletionRequested);
    on<AccountTypeDeleted>(_onAccountTypeDeleted);
  }

  final PortfolioRepository _portfolioRepository;

  Future<void> _onSubscriptionRequested(
    AccountTypeSubscriptionRequested event,
    Emitter<AccountTypeListState> emit,
  ) async {
    emit(state.copyWith(status: () => AccountTypeListStatus.loading));

    await emit.forEach<List<AccountType>>(
      _portfolioRepository.getAccountTypes(),
      onData: (accountTypes) => state.copyWith(
        status: () => AccountTypeListStatus.success,
        accountTypes: () => accountTypes,
      ),
      onError: (_, __) => state.copyWith(
        status: () => AccountTypeListStatus.failure,
      ),
    );
  }

  Future<void> _onAccountTypeDeleted(
    AccountTypeDeleted event,
    Emitter<AccountTypeListState> emit,
  ) async {
    await _portfolioRepository.deleteAccountType(event.accountType.id);
    emit(
      state.copyWith(
        status: () => AccountTypeListStatus.success,
        lastDeletedAccountType: () => event.accountType,
      ),
    );
  }

  Future<void> _onUndoDeletionRequested(
    AccountTypeUndoDeletionRequested event,
    Emitter<AccountTypeListState> emit,
  ) async {
    assert(
      state.lastDeletedAccountType != null,
      'Last deleted account type can not be null.',
    );

    final accountType = state.lastDeletedAccountType!;
    emit(state.copyWith(lastDeletedAccountType: () => null));
    await _portfolioRepository.saveAccountType(accountType);
  }
}
