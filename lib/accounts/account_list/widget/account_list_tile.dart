import 'package:flutter/material.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';

class AccountListTile extends StatelessWidget {
  const AccountListTile({
    required this.account,
    super.key,
    this.onDismissed,
    this.onTap,
    this.confirmDismiss,
  });

  final Account account;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;
  final ConfirmDismissCallback? confirmDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('accountListTile_dismissible_${account.id}'),
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
      child: ListTile(
        onTap: onTap,
        title: Text(
          '${account.name} - ${account.accountType?.type}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          account.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      ),
    );
  }
}
