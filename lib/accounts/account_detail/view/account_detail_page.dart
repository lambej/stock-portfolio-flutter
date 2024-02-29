import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/accounts/accounts.dart';
import 'package:stock_portfolio/l10n/l10n.dart';

class AccountDetailPage extends StatefulWidget {
  const AccountDetailPage({super.key});
  @override
  State<AccountDetailPage> createState() => _AccountDetailState();
}

class _AccountDetailState extends State<AccountDetailPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountDetailCubit, AccountDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${state.account.name} - ${state.account.accountType?.type}',
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final account = await Navigator.of(context).push(
                    EditAccountPage.route(
                      initialAccount: state.account,
                    ),
                  );
                  // When a BuildContext is used from a StatefulWidget,
                  // the mounted property must be checked
                  // after an asynchronous gap.
                  if (!mounted) return;
                  if (account != null) {
                    context.read<AccountDetailCubit>().setAccount(account);
                  }
                },
              ),
            ],
          ),
          body: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: SizedBox(
                  height: 50,
                  child: TabBar(
                    indicatorColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    labelColor: Colors.blue,
                    tabs: [
                      Tab(
                        text: AppLocalizations.of(context).positionsTabTitle,
                      ),
                      Tab(
                        text:
                            AppLocalizations.of(context).contributionsTabTitle,
                      ),
                    ],
                  ),
                ),
              ),
              body: TabBarView(
                children: [
                  Text('Positions'),
                  Text('Contributions'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
