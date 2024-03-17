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
                    const TableRow(
                      children: [
                        Text('Price 34'),
                        SizedBox(),
                        Text('P&L %: 34%'),
                        SizedBox(),
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
                    const TableRow(
                      children: [
                        Text('Cost Basis: %4102'),
                        SizedBox(),
                        Text(''),
                        SizedBox(),
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
