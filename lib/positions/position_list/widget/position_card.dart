import 'package:flutter/material.dart';
import 'package:stock_portfolio/api/model/position.dart';

class PositionCard extends StatelessWidget {
  const PositionCard(this.position, {super.key});
  final Position position;
  @override
  Widget build(BuildContext context) {
    return Card(
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
                        const Text('P&L %: 34%'),
                        const SizedBox(),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text('Shares: ${position.qtyOfShares}'),
                        const SizedBox(),
                        const Text('MV: %1102'),
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
    );
  }
}
