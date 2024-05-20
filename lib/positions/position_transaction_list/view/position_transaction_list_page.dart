// display the list of positions

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/positions/position_transaction_list/bloc/position_transaction_list_bloc.dart';
import 'package:stock_portfolio/positions/position_transaction_list/widget/position_card.dart';
import 'package:stock_portfolio/positions/widget/account_filter_button.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';

class PositionTransactionListPage extends StatelessWidget {
  const PositionTransactionListPage({super.key});
  static Route<Position> route({Position? initialPosition}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => PositionTransactionListBloc(
          portfolioRepository: context.read<PortfolioRepository>(),
        )..add(const LoadPositionTransactions()),
        child: const PositionTransactionListView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PositionTransactionListBloc(
        portfolioRepository: context.read<PortfolioRepository>(),
      )..add(const LoadPositionTransactions()),
      child: const PositionTransactionListView(),
    );
  }
}

class PositionTransactionListView extends StatelessWidget {
  const PositionTransactionListView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<PositionTransactionListBloc,
              PositionTransactionListState>(
            listenWhen: (previous, current) =>
                current.status == PositionTransactionListStatus.failure,
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
          BlocListener<PositionTransactionListBloc,
              PositionTransactionListState>(
            listenWhen: (previous, current) =>
                previous.lastDeletedTransaction !=
                    current.lastDeletedTransaction &&
                current.lastDeletedTransaction != null,
            listener: (context, state) {
              final deletedPosition = state.lastDeletedTransaction!;
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
                        context.read<PositionTransactionListBloc>().add(
                              UndoDeletePositionTransaction(deletedPosition),
                            );
                      },
                    ),
                  ),
                );
            },
          ),
        ],
        child: BlocBuilder<PositionTransactionListBloc,
            PositionTransactionListState>(
          builder: (context, state) {
            if (state.status == PositionTransactionListStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status != PositionTransactionListStatus.success) {
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
                            context.read<PositionTransactionListBloc>().add(
                                  PositionTransactionListAccountsFilterChanged(
                                    results,
                                  ),
                                );
                            context
                                .read<PositionTransactionListBloc>()
                                .add(const LoadPositionTransactions());
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.transactions.length,
                          itemBuilder: (context, index) {
                            final position = state.transactions[index];

                            return PositionCard(
                              position: position,
                              onDismissed: (_) {
                                context
                                    .read<PositionTransactionListBloc>()
                                    .add(DeletePositionTransaction(position));
                              },
                              confirmDismiss: (_) async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Are you sure you want to delete?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                log('Deletion confirmed: $confirmed');
                                return confirmed;
                              },
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
    );
  }
}
