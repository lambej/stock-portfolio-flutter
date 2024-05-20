import 'package:flutter/material.dart';
import 'package:stock_portfolio/api/model/position.dart';
import 'package:stock_portfolio/routes/routes.dart';

class PositionCard extends StatelessWidget {
  const PositionCard({
    required this.position,
    required this.totalValue,
    super.key,
    this.onDismissed,
    this.onTap,
    this.confirmDismiss,
  });

  final Position position;
  final double totalValue;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;
  final ConfirmDismissCallback? confirmDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(10),
              },
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        position.ticker,
                        style: MediaQuery.of(context).size.width < 500
                            ? Theme.of(context).textTheme.titleSmall
                            : Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(10),
                        1: FlexColumnWidth(),
                        2: FlexColumnWidth(10),
                        3: FlexColumnWidth(),
                      },
                      children: [
                        TableRow(
                          children: [
                            Text(
                              'Price: \$${position.currentPrice ?? 0}',
                              style: MediaQuery.of(context).size.width < 500
                                  ? Theme.of(context).textTheme.titleSmall
                                  : Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(),
                            Text(
                              'P&L %: ${position.profit.toStringAsFixed(2)}%',
                              style: MediaQuery.of(context).size.width < 500
                                  ? Theme.of(context).textTheme.titleSmall
                                  : Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(
                              'Shares: ${position.totalShares ?? position.qtyOfShares}',
                              style: MediaQuery.of(context).size.width < 500
                                  ? Theme.of(context).textTheme.titleSmall
                                  : Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(),
                            Text(
                              'MV: \$${position.marketValue}',
                              style: MediaQuery.of(context).size.width < 500
                                  ? Theme.of(context).textTheme.titleSmall
                                  : Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(
                              'CB: \$${position.costBasis ?? position.cost}',
                              style: MediaQuery.of(context).size.width < 500
                                  ? Theme.of(context).textTheme.titleSmall
                                  : Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(),
                            Text(
                              'Weight: ${(position.marketValue / totalValue * 100).toStringAsFixed(2)}%',
                              style: MediaQuery.of(context).size.width < 500
                                  ? Theme.of(context).textTheme.titleSmall
                                  : Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
