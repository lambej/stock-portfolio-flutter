import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/stock/repository/finnhub_stock_repository.dart';
import 'package:stock_portfolio/stock/stock_list/bloc/bloc/stock_list_bloc.dart';

// stateless widget
class StockListPage extends StatelessWidget {
  const StockListPage({super.key});
  static Page<void> page() => MaterialPage<void>(
        child: BlocProvider(
          create: (context) => StockListBloc(
            stockRepository: context.read<FinnhubRepository>(),
          )..add(const StockListRequested('AAPL')),
          child: const StockListPage(),
        ),
      );
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StockListBloc, StockListState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state.status == StockListStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state.status == StockListStatus.success) {
          final stockModel = state.stockModel;
          return Center(
            child: Column(
              children: [
                Text(stockModel?.tickerSymbol ?? ''),
                Text(stockModel?.currentPrice.toString() ?? ''),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}
