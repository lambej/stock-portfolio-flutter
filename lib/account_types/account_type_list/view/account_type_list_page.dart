import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/account_types/account_type.dart';
import 'package:stock_portfolio/account_types/edit_account_type/edit_account_type.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';

class AccountTypePage extends StatelessWidget {
  const AccountTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountTypeListBloc(
        portfolioRepository: context.read<PortfolioRepository>(),
      )..add(AccountTypeSubscriptionRequested()),
      child: const AccountTypeView(),
    );
  }
}

class AccountTypeView extends StatelessWidget {
  const AccountTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AccountTypeListBloc, AccountTypeListState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == AccountTypeListStatus.failure) {
                final errorText = l10n.accountTypeErrorSnackbarText;

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(errorText),
                    ),
                  );
              }
            },
          ),
          BlocListener<AccountTypeListBloc, AccountTypeListState>(
            listenWhen: (previous, current) =>
                previous.lastDeletedAccountType !=
                    current.lastDeletedAccountType &&
                current.lastDeletedAccountType != null,
            listener: (context, state) {
              final deletedAccountType = state.lastDeletedAccountType!;
              final messenger = ScaffoldMessenger.of(context);
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.accountTypeDeletedSnackbarText(
                        deletedAccountType.type,
                      ),
                    ),
                    action: SnackBarAction(
                      label: l10n.accountTypeUndoDeletionButtonText,
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                        context
                            .read<AccountTypeListBloc>()
                            .add(AccountTypeUndoDeletionRequested());
                      },
                    ),
                  ),
                );
            },
          ),
        ],
        child: BlocBuilder<AccountTypeListBloc, AccountTypeListState>(
          builder: (context, state) {
            if (state.accountTypes.isEmpty) {
              if (state.status == AccountTypeListStatus.loading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state.status != AccountTypeListStatus.success) {
                return const SizedBox();
              } else {
                return Center(
                  child: Text(
                    l10n.accountTypeEmptyText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
            }

            return CupertinoScrollbar(
              child: ListView(
                children: [
                  for (final accountType in state.accountTypes)
                    AccountTypeListTile(
                      accountType: accountType,
                      onDismissed: (_) async {
                        context
                            .read<AccountTypeListBloc>()
                            .add(AccountTypeDeleted(accountType));
                      },
                      onTap: () {
                        Navigator.of(context).push(
                          EditAccountTypePage.route(
                            initialAccountType: accountType,
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
        key: const Key('AccountTypeView_addAccountType_floatingActionButton'),
        shape: const StadiumBorder(),
        onPressed: () =>
            Navigator.of(context).push(EditAccountTypePage.route()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
