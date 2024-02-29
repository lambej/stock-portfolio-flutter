import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/accounts/accounts.dart';
import 'package:stock_portfolio/app/app.dart';
import 'package:stock_portfolio/app/view/drawer.dart';
import 'package:stock_portfolio/home/home.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/overview/overview.dart';
//import 'package:stock_portfolio/portfolio_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeViewState();
  static Page<void> page() => MaterialPage<void>(
        child: BlocProvider<HomeCubit>(
          create: (_) => HomeCubit(),
          child: const HomePage(),
        ),
      );
}

class _HomeViewState extends State<HomePage> {
  late HomeTab selectedTab;
  @override
  Widget build(BuildContext context) {
    selectedTab = context.select((HomeCubit cubit) => cubit.state.tab);
    // init portfolio api user
    //selectedTab = HomeTab.overview;
    return //MultiBlocProvider(
        // providers: [
        // BlocProvider<OverviewBloc>(
        //   create: (_) => OverviewBloc(
        //     portfolioRepository: context.read<PortfolioRepository>(),
        //   )..add(const ReturnSubscriptionRequested()),
        // ),
        // BlocProvider<ReturnsChartBloc>(
        //   create: (_) => ReturnsChartBloc(
        //     portfolioRepository: context.read<PortfolioRepository>(),
        //   )..add(const ReturnsChartRequested()),
        // ),
        // BlocProvider<BalancesChartBloc>(
        //   create: (_) => BalancesChartBloc(
        //     portfolioRepository: context.read<PortfolioRepository>(),
        //   )..add(const BalancesChartRequested()),
        // ),
        // BlocProvider<AccountDistributionChartBloc>(
        //   create: (_) => AccountDistributionChartBloc(
        //     portfolioRepository: context.read<PortfolioRepository>(),
        //   )..add(const AccountDistributionChartRequested()),
        // ),
        // BlocProvider<CashflowChartBloc>(
        //   create: (_) => CashflowChartBloc(
        //     portfolioRepository: context.read<PortfolioRepository>(),
        //   )..add(const CashflowChartRequested()),
        // ),
        // ],
        // child:
        Scaffold(
      appBar: AppBar(
        title: //title change depending on the selected tab
            selectedTab == HomeTab.overview
                ? Text(AppLocalizations.of(context).overview)
                : selectedTab == HomeTab.accounts
                    ? Text(AppLocalizations.of(context).accounts)
                    : Text(AppLocalizations.of(context).charts),
      ),
      drawer: const AppStructure(),
      body: IndexedStack(
        index: selectedTab.index,
        children: const [OverviewPage(), AccountsPage(), Text('Charts')],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _HomeTabButton(
              groupValue: selectedTab,
              value: HomeTab.overview,
              icon: const Icon(Icons.list_rounded),
            ),
            _HomeTabButton(
              groupValue: selectedTab,
              value: HomeTab.accounts,
              icon: const Icon(Icons.account_balance_wallet_rounded),
            ),
            _HomeTabButton(
              groupValue: selectedTab,
              value: HomeTab.charts,
              icon: const Icon(Icons.show_chart_rounded),
            ),
          ],
        ),
      ),
      //  ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().setTab(HomeTab.overview);
  }
}

class _HomeTabButton extends StatelessWidget {
  const _HomeTabButton({
    required this.groupValue,
    required this.value,
    required this.icon,
  });

  final HomeTab groupValue;
  final HomeTab value;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<HomeCubit>().setTab(value);
        // BlocProvider.of<OverviewBloc>(context)
        //     .add(const ReturnSubscriptionRequested());
      },
      iconSize: 32,
      color:
          groupValue != value ? null : Theme.of(context).colorScheme.secondary,
      icon: icon,
    );
  }
}
