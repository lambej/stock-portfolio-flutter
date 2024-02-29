import 'package:flutter/material.dart';
import 'package:stock_portfolio/account_types/account_type_list/account_type_list.dart';
import 'package:stock_portfolio/accounts/accounts.dart';
import 'package:stock_portfolio/l10n/l10n.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
                  text: AppLocalizations.of(context).accountAppBarTitle,
                ),
                Tab(
                  text: AppLocalizations.of(context).accountTypeAppBarTitle,
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            AccountListPage(),
            AccountTypePage(),
          ],
        ),
      ),
    );
  }
}
