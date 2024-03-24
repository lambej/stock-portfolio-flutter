// display the list of positions

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/positions/edit_position/edit_position.dart';
import 'package:stock_portfolio/positions/position_list/bloc/position_list_bloc.dart';
import 'package:stock_portfolio/positions/position_list/widget/widget.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';
import 'package:stock_portfolio/stock/repository/finnhub_stock_repository.dart';

class PositionListPage extends StatelessWidget {
  const PositionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PositionListBloc(
        portfolioRepository: context.read<PortfolioRepository>(),
        stockRepository: context.read<FinnhubRepository>(),
      )..add(const LoadPositions()),
      child: const PositionListView(),
    );
  }
}

class PositionListView extends StatelessWidget {
  const PositionListView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: BlocConsumer<PositionListBloc, PositionListState>(
        listener: (context, state) {
          if (state is PositionListError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.error.toString()),
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is PositionListLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is PositionListLoaded) {
            return Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ), // Set the maximum width here
                child: ListView.builder(
                  itemCount: state.positions.length,
                  itemBuilder: (context, index) {
                    final position = state.positions[index];
                    return PositionCard(position);
                  },
                ),
              ),
            );
          } else {
            return const Center(
              child: Text('Failed to load positions'),
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        key: const Key('Overview_addPosition_floatingActionButton'),
        shape: const StadiumBorder(),
        onPressed: () {
          Navigator.of(context).push(EditPositionPage.route());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
