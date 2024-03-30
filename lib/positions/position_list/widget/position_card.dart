import 'package:flutter/material.dart';
import 'package:stock_portfolio/api/model/position.dart';
import 'package:stock_portfolio/routes/routes.dart';

class PositionCard extends StatelessWidget {
  const PositionCard({
    required this.position,
    super.key,
    this.onDismissed,
    this.onTap,
    this.confirmDismiss,
  });

  final Position position;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;
  final ConfirmDismissCallback? confirmDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('positionCard_dismissible_${position.id}'),
      onDismissed: onDismissed,
      confirmDismiss: confirmDismiss,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: theme.colorScheme.error,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(
          Icons.delete,
          color: Color(0xAAFFFFFF),
        ),
      ),
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
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(4),
                        1: FlexColumnWidth(),
                        2: FlexColumnWidth(3),
                        3: FlexColumnWidth(),
                      },
                      children: [
                        TableRow(
                          children: [
                            Text('Price \$${position.currentPrice}'),
                            const SizedBox(),
                            Text('P&L %: ${position.profit}%'),
                            const SizedBox(),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text('Shares: ${position.totalShares}'),
                            const SizedBox(),
                            Text('MV: \$${position.marketValue}'),
                            const SizedBox(),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(
                              'Cost Basis: \$${position.costBasis ?? position.cost}',
                            ),
                            const SizedBox(),
                            const Text(''),
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
