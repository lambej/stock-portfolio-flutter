import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';

part 'edit_account_type_event.dart';
part 'edit_account_type_state.dart';

class EditAccountTypeBloc
    extends Bloc<EditAccountTypeEvent, EditAccountTypeState> {
  EditAccountTypeBloc({
    required PortfolioRepository portfolioRepository,
    required AccountType? initialAccountType,
  })  : _portfolioRepository = portfolioRepository,
        super(
          EditAccountTypeState(
            initialAccountType: initialAccountType,
            type: initialAccountType?.type ?? '',
          ),
        ) {
    on<EditAccountTypeTypeChanged>(_onTypeChanged);
    on<EditAccountTypeSubmitted>(_onSubmitted);
  }

  final PortfolioRepository _portfolioRepository;

  void _onTypeChanged(
    EditAccountTypeTypeChanged event,
    Emitter<EditAccountTypeState> emit,
  ) {
    emit(state.copyWith(type: event.type));
  }

  Future<void> _onSubmitted(
    EditAccountTypeSubmitted event,
    Emitter<EditAccountTypeState> emit,
  ) async {
    emit(state.copyWith(status: EditAccountTypeStatus.loading));
    final accountType =
        (state.initialAccountType ?? AccountType(type: '', userId: ''))
            .copyWith(
      type: state.type,
    );

    try {
      if (state.isNewAccountType &&
          _portfolioRepository.maxAccountTypeReached) {
        emit(state.copyWith(status: EditAccountTypeStatus.maxReached));
        return;
      }

      await _portfolioRepository.saveAccountType(accountType);
      emit(state.copyWith(status: EditAccountTypeStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditAccountTypeStatus.failure));
    }
  }
}
