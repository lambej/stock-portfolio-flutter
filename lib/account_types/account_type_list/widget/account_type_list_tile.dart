import 'package:flutter/material.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';

class AccountTypeListTile extends StatelessWidget {
  const AccountTypeListTile({
    required this.accountType,
    super.key,
    this.onDismissed,
    this.onTap,
  });

  final AccountType accountType;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('accountTypeListTile_dismissible_${accountType.id}'),
      onDismissed: onDismissed,
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
      child: ListTile(
        onTap: onTap,
        title: Text(
          accountType.type,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      ),
    );
  }
}
