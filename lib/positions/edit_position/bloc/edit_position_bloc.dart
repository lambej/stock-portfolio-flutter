import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';

part 'edit_position_event.dart';
part 'edit_position_state.dart';

class EditPositionBloc extends Bloc<EditPositionEvent, EditPositionState> {
  EditPositionBloc({
    required PortfolioRepository portfolioRepository,
    required Position? initialPosition,
  })  : _portfolioRepository = portfolioRepository,
        super(
          EditPositionState(
            initialPosition: initialPosition,
            ticker: initialPosition?.ticker ?? '',
            qtyOfShares: initialPosition?.qtyOfShares ?? 0,
            cost: initialPosition?.cost ?? 0,
          ),
        ) {
    on<EditPositionEvent>((event, emit) {});

    on<EditPositionSubmitted>((event, emit) async {
      final position = (state.initialPosition ??
              Position(
                ticker: '',
                qtyOfShares: 0,
                cost: 0,
                currency: '',
                userId: '',
                accountId: '',
              ))
          .copyWith(
        ticker: state.ticker,
        qtyOfShares: state.qtyOfShares,
        cost: state.cost,
        accountId: state.account?.id,
      );
      if (state.isNewPosition && _portfolioRepository.maxAccountReached) {
        emit(EditPositionMaxReached());
        return;
      }
      try {
        await _portfolioRepository.savePosition(position);
        emit(state.copyWith(status: EditPositionStatus.success));
      } catch (e) {
        emit(state.copyWith(status: EditPositionStatus.failure));
      }
    });
    on<EditPositionTickerChanged>(_onTickerChanged);
    on<EditPositionAccountChanged>(_onAccountChanged);
    on<EditPositionQtyOfSharesChanged>(_onQtyOfSharesChanged);
  }
  final PortfolioRepository _portfolioRepository;

  void _onTickerChanged(
    EditPositionTickerChanged event,
    Emitter<EditPositionState> emit,
  ) {
    emit(
      state.copyWith(ticker: event.ticker),
    );
  }

  void _onAccountChanged(
    EditPositionAccountChanged event,
    Emitter<EditPositionState> emit,
  ) {
    emit(
      state.copyWith(account: event.account),
    );
  }

  void _onQtyOfSharesChanged(
    EditPositionQtyOfSharesChanged event,
    Emitter<EditPositionState> emit,
  ) {
    emit(
      state.copyWith(qtyOfShares: event.qtyOfShares),
    );
  }
}
