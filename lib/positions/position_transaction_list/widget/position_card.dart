import 'package:flutter/material.dart';
import 'package:stock_portfolio/api/model/position.dart';

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
      key: Key('transaction_dismissible_${position.id}'),
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
                1: FlexColumnWidth(4),
                2: FlexColumnWidth(4),
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Shares: ${position.qtyOfShares}',
                        style: MediaQuery.of(context).size.width < 500
                            ? Theme.of(context).textTheme.titleSmall
                            : Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'CB: \$${position.cost}',
                        style: MediaQuery.of(context).size.width < 500
                            ? Theme.of(context).textTheme.titleSmall
                            : Theme.of(context).textTheme.titleMedium,
                      ),
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
