import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';

part 'edit_account_event.dart';
part 'edit_account_state.dart';

class EditAccountBloc extends Bloc<EditAccountEvent, EditAccountState> {
  EditAccountBloc({
    required PortfolioRepository portfolioRepository,
    required Account? initialAccount,
  })  : _portfolioRepository = portfolioRepository,
        super(
          EditAccountState(
            initialAccount: initialAccount,
            type: initialAccount?.accountType,
            name: initialAccount?.name ?? '',
            description: initialAccount?.description ?? '',
          ),
        ) {
    on<EditAccountTypeChanged>(_onTypeChanged);
    on<EditAccountNameChanged>(_onNameChanged);
    on<EditAccountDescriptionChanged>(_onDescriptionChanged);
    on<EditAccountSubmitted>(_onSubmitted);
  }

  final PortfolioRepository _portfolioRepository;

  void _onTypeChanged(
    EditAccountTypeChanged event,
    Emitter<EditAccountState> emit,
  ) {
    emit(state.copyWith(type: event.type));
  }

  void _onNameChanged(
    EditAccountNameChanged event,
    Emitter<EditAccountState> emit,
  ) {
    emit(state.copyWith(name: event.name));
  }

  void _onDescriptionChanged(
    EditAccountDescriptionChanged event,
    Emitter<EditAccountState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  Future<void> _onSubmitted(
    EditAccountSubmitted event,
    Emitter<EditAccountState> emit,
  ) async {
    emit(state.copyWith(status: EditAccountStatus.loading));
    final account = (state.initialAccount ??
            Account(
              name: '',
              accountType: AccountType(type: '', userId: ''),
              userId: '',
            ))
        .copyWith(
      name: state.name,
      accountType: state.type,
      description: state.description,
    );
    if (state.isNewAccount && _portfolioRepository.maxAccountReached) {
      emit(state.copyWith(status: EditAccountStatus.maxReached));
      return;
    }
    try {
      await _portfolioRepository.saveAccount(account);
      emit(state.copyWith(status: EditAccountStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditAccountStatus.failure));
    }
  }
}
