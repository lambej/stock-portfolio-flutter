import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/api/service/user_shared_pref_service.dart';
import 'package:stock_portfolio/app/app.dart';
import 'package:stock_portfolio/authentication/repository/authentication_repository.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';
import 'package:stock_portfolio/routes/routes.dart';
import 'package:stock_portfolio/stock/repository/finnhub_stock_repository.dart';
import 'package:stock_portfolio/theme/theme.dart';

class App extends StatelessWidget {
  const App({
    required FinnhubRepository stockRepository,
    required AuthenticationRepository authenticationRepository,
    required PortfolioRepository portfolioRepository,
    required UserSharedPrefService userSharedPrefService,
    super.key,
  })  : _stockRepository = stockRepository,
        _authenticationRepository = authenticationRepository,
        _portfolioRepository = portfolioRepository,
        _userSharedPrefService = userSharedPrefService;
  final FinnhubRepository _stockRepository;
  final AuthenticationRepository _authenticationRepository;
  final PortfolioRepository _portfolioRepository;
  final UserSharedPrefService _userSharedPrefService;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FinnhubRepository>(
          create: (context) => _stockRepository,
        ),
        RepositoryProvider.value(
          value: _authenticationRepository,
        ),
        RepositoryProvider.value(
          value: _portfolioRepository,
        ),
        RepositoryProvider<UserSharedPrefService>(
          create: (context) => _userSharedPrefService,
        ),
      ],
      child: BlocProvider(
        create: (_) => AppBloc(
          authenticationRepository: _authenticationRepository,
          stockRepository: _stockRepository,
          portfolioRepository: _portfolioRepository,
          userSharedPrefService: _userSharedPrefService,
        ),
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            return MaterialApp(
              theme: FlutterTheme.light,
              darkTheme: FlutterTheme.dark,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: FlowBuilder<AppStatus>(
                state: context.select((AppBloc bloc) => bloc.state.status),
                onGeneratePages: onGenerateAppViewPages,
              ),
            );
          },
        ),
      ),
    );
  }
}
