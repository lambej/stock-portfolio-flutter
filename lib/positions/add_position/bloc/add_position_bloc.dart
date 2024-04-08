import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';

part 'add_position_event.dart';
part 'add_position_state.dart';

class AddPositionBloc extends Bloc<AddPositionEvent, AddPositionState> {
  AddPositionBloc({
    required PortfolioRepository portfolioRepository,
    required Position? initialPosition,
  })  : _portfolioRepository = portfolioRepository,
        super(
          AddPositionState(
            initialPosition: initialPosition,
            ticker: initialPosition?.ticker ?? '',
            qtyOfShares: initialPosition?.qtyOfShares ?? 0,
            cost: initialPosition?.cost ?? 0,
            account: initialPosition?.account,
          ),
        ) {
    on<AddPositionEvent>((event, emit) {});

    on<AddPositionSubmitted>((event, emit) async {
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
        qtyOfShares: state.action == PositionAction.buy
            ? state.qtyOfShares
            : -state.qtyOfShares,
        cost: state.cost,
        account: state.account,
      );
      if (state.isNewPosition && _portfolioRepository.maxAccountReached) {
        emit(AddPositionMaxReached());
        return;
      }
      try {
        await _portfolioRepository.savePosition(position);
        emit(state.copyWith(status: AddPositionStatus.success));
      } catch (e) {
        emit(state.copyWith(status: AddPositionStatus.failure));
      }
    });
    on<AddPositionTickerChanged>(_onTickerChanged);
    on<AddPositionAccountChanged>(_onAccountChanged);
    on<AddPositionQtyOfSharesChanged>(_onQtyOfSharesChanged);
    on<AddPositionCostChanged>(_onCostChanged);
    on<AddPositionActionChanged>(_onActionChanged);
  }
  final PortfolioRepository _portfolioRepository;

  void _onTickerChanged(
    AddPositionTickerChanged event,
    Emitter<AddPositionState> emit,
  ) {
    emit(
      state.copyWith(ticker: event.ticker),
    );
  }

  void _onAccountChanged(
    AddPositionAccountChanged event,
    Emitter<AddPositionState> emit,
  ) {
    emit(
      state.copyWith(account: event.account),
    );
  }

  void _onQtyOfSharesChanged(
    AddPositionQtyOfSharesChanged event,
    Emitter<AddPositionState> emit,
  ) {
    emit(
      state.copyWith(qtyOfShares: event.qtyOfShares),
    );
  }

  void _onCostChanged(
    AddPositionCostChanged event,
    Emitter<AddPositionState> emit,
  ) {
    emit(
      state.copyWith(cost: event.cost),
    );
  }

  void _onActionChanged(
    AddPositionActionChanged event,
    Emitter<AddPositionState> emit,
  ) {
    emit(
      state.copyWith(action: event.action),
    );
  }
}
