import 'package:flutter/material.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/positions/position_list/view/position_list_page.dart';
import 'package:stock_portfolio/positions/position_transaction_list/view/position_transaction_list_page.dart';

class PositionsPage extends StatelessWidget {
  const PositionsPage({super.key});

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
                  text: AppLocalizations.of(context).positions,
                ),
                Tab(
                  text: AppLocalizations.of(context).transactions,
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            PositionListPage(),
            PositionTransactionListPage(),
          ],
        ),
      ),
    );
  }
}
