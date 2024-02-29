import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/accounts/accounts.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';

class AccountListPage extends StatelessWidget {
  const AccountListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountListBloc(
        portfolioRepository: context.read<PortfolioRepository>(),
      )..add(AccountListSubscriptionRequested()),
      child: const AccountListView(),
    );
  }
}

class AccountListView extends StatelessWidget {
  const AccountListView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AccountListBloc, AccountListState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == AccountListStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.accountErrorSnackbarText),
                    ),
                  );
              }
            },
          ),
          BlocListener<AccountListBloc, AccountListState>(
            listenWhen: (previous, current) =>
                previous.lastDeletedAccount != current.lastDeletedAccount &&
                current.lastDeletedAccount != null,
            listener: (context, state) {
              final deletedAccount = state.lastDeletedAccount!;
              final messenger = ScaffoldMessenger.of(context);
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.accountDeletedSnackbarText(
                        deletedAccount.name,
                      ),
                    ),
                    action: SnackBarAction(
                      label: l10n.accountUndoDeletionButtonText,
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                        context
                            .read<AccountListBloc>()
                            .add(AccountListUndoDeletionRequested());
                      },
                    ),
                  ),
                );
            },
          ),
        ],
        child: BlocBuilder<AccountListBloc, AccountListState>(
          builder: (context, state) {
            if (state.accounts.isEmpty) {
              if (state.status == AccountListStatus.loading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state.status != AccountListStatus.success) {
                return const SizedBox();
              } else {
                return Center(
                  child: Text(
                    l10n.accountEmptyText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
            }

            return CupertinoScrollbar(
              child: ListView(
                children: [
                  for (final account in state.accounts)
                    AccountListTile(
                      account: account,
                      onDismissed: (_) {
                        context
                            .read<AccountListBloc>()
                            .add(AccountListDeleted(account));
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
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );
                        log('Deletion confirmed: $confirmed');
                        return confirmed;
                      },
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<AccountDetailPage>(
                            fullscreenDialog: true,
                            builder: (context) => BlocProvider(
                              create: (context) => AccountDetailCubit(account),
                              child: const AccountDetailPage(),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        key: const Key('AccountListView_addAccount_floatingActionButton'),
        shape: const StadiumBorder(),
        onPressed: () => Navigator.of(context).push(EditAccountPage.route()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
