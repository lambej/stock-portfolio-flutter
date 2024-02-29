import 'package:stock_portfolio/app/app.dart';
import 'package:stock_portfolio/authentication/repository/authentication_repository.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';
import 'package:stock_portfolio/routes/routes.dart';
import 'package:stock_portfolio/stock/repository/finnhub_stock_repository.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({
    required FinnhubRepository stockRepository,
    required AuthenticationRepository authenticationRepository,
    required PortfolioRepository portfolioRepository,
    super.key,
  })  : _stockRepository = stockRepository,
        _authenticationRepository = authenticationRepository,
        _portfolioRepository = portfolioRepository;
  final FinnhubRepository _stockRepository;
  final AuthenticationRepository _authenticationRepository;
  final PortfolioRepository _portfolioRepository;

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
      ],
      child: BlocProvider(
        create: (_) => AppBloc(
          authenticationRepository: _authenticationRepository,
          stockRepository: _stockRepository,
        ),
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            return MaterialApp(
              theme: ThemeData(
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color.fromARGB(255, 5, 142, 196),
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Color.fromARGB(255, 5, 142, 196),
                ),
                useMaterial3: true,
              ),
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
