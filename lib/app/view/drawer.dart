import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/app/bloc/app_bloc.dart';
import 'package:stock_portfolio/l10n/l10n.dart';

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
                accountName: Text(state.user.name ?? ''),
                accountEmail: Text(state.user.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  foregroundImage: state.user.photo != null
                      ? NetworkImage(
                          state.user.photo!,
                        )
                      : null,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
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
