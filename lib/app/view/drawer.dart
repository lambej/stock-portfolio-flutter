import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/api/model/currency_enum.dart';
import 'package:stock_portfolio/app/bloc/app_bloc.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/positions/position_transaction_list/view/position_transaction_list_page.dart';

class AppStructure extends StatelessWidget {
  const AppStructure({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                accountName: Text(
                  state.user.name ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                accountEmail: Text(
                  state.user.email ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  foregroundImage: state.user.photo != null
                      ? NetworkImage(
                          state.user.photo!,
                        )
                      : null,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Text(
                    state.user.name
                            ?.trim()
                            .split(RegExp(' +'))
                            .map((s) => s[0])
                            .join() ??
                        '',
                  ),
                ),
              ),
              // add a dropdown menu to choose language
              ListTile(
                leading: const Icon(Icons.currency_exchange),
                title: Text(AppLocalizations.of(context).currency),
                onTap: () {
                  Navigator.pop(context);
                  showDialog<void>(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text(AppLocalizations.of(context).currency),
                        children: [
                          ListTile(
                            title: const Text('USD'),
                            onTap: () {
                              context.read<AppBloc>().add(
                                    const AppCurrencyChanged(
                                      Currency.usd,
                                    ),
                                  );
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text('CAD'),
                            onTap: () {
                              context.read<AppBloc>().add(
                                    const AppCurrencyChanged(
                                      Currency.cad,
                                    ),
                                  );
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(AppLocalizations.of(context).logout),
                onTap: () {
                  context.read<AppBloc>().add(
                        const AppLogoutRequested(),
                      );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
