// display the list of positions

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/positions/add_position/add_position.dart';
import 'package:stock_portfolio/positions/position_list/bloc/position_list_bloc.dart';
import 'package:stock_portfolio/positions/position_list/widget/account_filter_button.dart';
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<PositionListBloc, PositionListState>(
            listenWhen: (previous, current) =>
                current.status == PositionListStatus.failure,
            listener: (context, state) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(l10n.positionErrorSnackbarText),
                  ),
                );
            },
          ),
          BlocListener<PositionListBloc, PositionListState>(
            listenWhen: (previous, current) =>
                previous.lastDeletedPosition != current.lastDeletedPosition &&
                current.lastDeletedPosition != null,
            listener: (context, state) {
              final deletedPosition = state.lastDeletedPosition!;
              final messenger = ScaffoldMessenger.of(context);
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.positionDeletedSnackbarText(deletedPosition.ticker),
                    ),
                    action: SnackBarAction(
                      label: l10n.positionUndoDeletionButtonText,
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                        context
                            .read<PositionListBloc>()
                            .add(UndoDeletePosition(deletedPosition));
                      },
                    ),
                  ),
                );
            },
          ),
        ],
        child: BlocBuilder<PositionListBloc, PositionListState>(
          builder: (context, state) {
            if (state.status == PositionListStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status != PositionListStatus.success) {
              return const SizedBox();
            } else {
              return Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 600,
                  ), // Set the maximum width here
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: AccountFilterButton(
                          accounts: state.accounts,
                          initialValue: state.accountsFilter,
                          onChanged: (List<Account> results) {
                            context.read<PositionListBloc>().add(
                                  PositionListAccountsFilterChanged(results),
                                );
                            context
                                .read<PositionListBloc>()
                                .add(const LoadPositions());
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.positions.length,
                          itemBuilder: (context, index) {
                            final position = state.positions[index];

                            return PositionCard(
                              position: position,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        key: const Key('PositionList_addPosition_floatingActionButton'),
        shape: const StadiumBorder(),
        onPressed: () {
          Navigator.of(context).push(AddPositionPage.route());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
