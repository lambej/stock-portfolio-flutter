import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:stock_portfolio/api/model/currency_enum.dart';
import 'package:stock_portfolio/api/service/user_shared_pref_service.dart';
import 'package:stock_portfolio/authentication/authentication.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';
import 'package:stock_portfolio/stock/repository/finnhub_stock_repository.dart';

import 'package:equatable/equatable.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({
    required AuthenticationRepository authenticationRepository,
    required FinnhubRepository stockRepository,
    required PortfolioRepository portfolioRepository,
    required UserSharedPrefService userSharedPrefService,
  })  : _authenticationRepository = authenticationRepository,
        _stockRepository = stockRepository,
        _portfolioRepository = portfolioRepository,
        _userSharedPrefService = userSharedPrefService,
        super(
          authenticationRepository.currentUser.isNotEmpty
              ? AppState.authenticated(authenticationRepository.currentUser)
              : const AppState.unauthenticated(),
        ) {
    on<_AppUserChanged>(_onUserChanged);
    on<AppLoaded>((event, emit) => emit(AppState.appLoaded(event.user)));
    on<AppLogoutRequested>(_onLogoutRequested);
    on<AppCurrencyChanged>((event, emit) {
      _userSharedPrefService.setCurrencyPref(event.currency);
    });

    _userSubscription = _authenticationRepository.user.listen((user) {
      if (user.isNotEmpty) {
        _portfolioRepository
            .init(authenticationRepository.currentUser.id)
            .then((value) {
          add(AppLoaded(authenticationRepository.currentUser));
        });
      } else {
        add(_AppUserChanged(user));
      }
    });
  }

  final AuthenticationRepository _authenticationRepository;
  final FinnhubRepository _stockRepository;
  final PortfolioRepository _portfolioRepository;
  final UserSharedPrefService _userSharedPrefService;

  late final StreamSubscription<User> _userSubscription;
  void _onUserChanged(_AppUserChanged event, Emitter<AppState> emit) {
    emit(
      event.user.isNotEmpty
          ? AppState.authenticated(event.user)
          : const AppState.unauthenticated(),
    );
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
