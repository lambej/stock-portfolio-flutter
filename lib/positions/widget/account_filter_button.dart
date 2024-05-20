import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';

class AccountFilterButton extends StatelessWidget {
  const AccountFilterButton({
    required this.accounts,
    required this.initialValue,
    required this.onChanged,
    super.key,
  });
  final List<Account> accounts;
  final List<Account> initialValue;
  final ValueChanged<List<Account>> onChanged;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final items = accounts
        .map((account) => MultiSelectItem<Account>(account, account.name))
        .toList();
    return MultiSelectDialogField<Account>(
      initialValue: initialValue,
      items: items,
      listType: MultiSelectListType.CHIP,
      cancelText: Text(
        l10n.cancel,
        style: const TextStyle(color: Colors.white),
      ),
      confirmText: Text(
        l10n.ok,
        style: const TextStyle(color: Colors.white),
      ),
      title: Text(l10n.accountsAppBarTitle),
      selectedColor: Colors.blue,
      itemsTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      colorator: (Account account) => Colors.blue,
      chipDisplay: MultiSelectChipDisplay.none(),
      selectedItemsTextStyle:
          TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(40)),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
      ),
      buttonIcon: Icon(
        Icons.filter_list,
        color: Colors.blue[400],
      ),
      buttonText: Text(
        l10n.accountsAppBarTitle,
        style: TextStyle(
          color: Colors.blue[400],
          fontSize: 16,
        ),
      ),
      onConfirm: onChanged,
    );
  }
}
