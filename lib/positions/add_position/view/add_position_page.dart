import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/api/model/currency_enum.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/positions/add_position/add_position.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';
import 'package:stock_portfolio/shared/shared.dart';

class AddPositionPage extends StatelessWidget {
  const AddPositionPage({super.key});

  static Route<Position> route({Position? initialPosition}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => AddPositionBloc(
          portfolioRepository: context.read<PortfolioRepository>(),
          initialPosition: initialPosition,
        ),
        child: const AddPositionPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AddPositionBloc, AddPositionState>(
          listenWhen: (previous, current) =>
              current.status != previous.status &&
              current.status == AddPositionStatus.success,
          listener: (context, state) => Navigator.of(context).pop(
            state.initialPosition?.copyWith(
              ticker: state.ticker,
              qtyOfShares: state.qtyOfShares,
              cost: state.cost,
            ),
          ),
        ),
        BlocListener<AddPositionBloc, AddPositionState>(
          listener: (context, state) {
            if (state is AddPositionMaxReached) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  elevation: 5,
                  content: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)
                              .addPositionMaxPositionSnackBar,
                        ),
                        TextSpan(
                          text: ' balancify.app',
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchURL('https://balancify.app');
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ],
      child: const AddPositionView(),
    );
  }
}

class AddPositionView extends StatelessWidget {
  const AddPositionView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isSuccess = context.select((AddPositionBloc bloc) =>
        bloc.state.status == AddPositionStatus.success);
    final isNewPosition = context.select(
      (AddPositionBloc bloc) => bloc.state.isNewPosition,
    );
    final theme = Theme.of(context);
    final floatingActionButtonTheme = theme.floatingActionButtonTheme;
    final fabBackgroundColor = floatingActionButtonTheme.backgroundColor ??
        theme.colorScheme.secondary;
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewPosition
              ? l10n.addPositionAddAppBarTitle
              : l10n.addPositionEditAppBarTitle,
        ),
      ),
      floatingActionButton: Tooltip(
        message: l10n.addPositionSaveButtonTooltip,
        child: MaterialButton(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          color: isSuccess
              ? fabBackgroundColor.withOpacity(0.5)
              : fabBackgroundColor,
          onPressed: isSuccess
              ? null
              : () {
                  if (formKey.currentState!.validate()) {
                    context
                        .read<AddPositionBloc>()
                        .add(const AddPositionSubmitted());
                  }
                },
          child: isSuccess
              ? const CupertinoActivityIndicator()
              : const Icon(Icons.check_rounded),
        ),
      ),
      body: CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: const Column(
                children: [
                  _AccountField(),
                  _TickerField(),
                  _ActionField(),
                  _CurrencyField(),
                  _QtyOfSharesField(),
                  _CostField(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountField extends StatelessWidget {
  const _AccountField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AddPositionBloc>().state;
    final hintText = state.initialPosition?.account?.name;

    return StreamBuilder<List<Account>>(
      stream: context.read<PortfolioRepository>().getAccounts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final isStateTypeExists =
              snapshot.data!.any((account) => account.id == state.account?.id);
          return DropdownButtonFormField<Account>(
            key: const Key('AddPositionView_account_dropdownFormField'),
            value: isStateTypeExists ? state.account : null,
            items: snapshot.data!.map((account) {
              return DropdownMenuItem<Account>(
                value: account,
                child: Text(account.name),
              );
            }).toList(),
            decoration: InputDecoration(
              enabled: !state.status.isLoadingOrSuccess,
              labelText: l10n.editAccountTypeLabel,
              hintText: hintText,
            ),
            onChanged: (Account? value) => context
                .read<AddPositionBloc>()
                .add(AddPositionAccountChanged(account: value!)),
            validator: (Account? value) {
              if (value == null) {
                return l10n.editAccountMissingType;
              }
              return null;
            },
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class _ActionField extends StatelessWidget {
  const _ActionField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AddPositionBloc>().state;
    final hintText = state.action.toString();

    return DropdownButtonFormField<PositionAction>(
      key: const Key('AddPositionView_action_dropdownFormField'),
      value: state.action,
      items: PositionAction.values.map((action) {
        return DropdownMenuItem<PositionAction>(
          value: action,
          child: Text(action.toString()),
        );
      }).toList(),
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editAccountTypeLabel,
        hintText: hintText,
      ),
      onChanged: (PositionAction? value) => context
          .read<AddPositionBloc>()
          .add(AddPositionActionChanged(action: value!)),
      validator: (PositionAction? value) {
        if (value == null) {
          return l10n.editAccountMissingType;
        }
        return null;
      },
    );
  }
}

class _CurrencyField extends StatelessWidget {
  const _CurrencyField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AddPositionBloc>().state;
    final hintText = state.action.toString();

    return DropdownButtonFormField<Currency>(
      key: const Key('AddPositionView_currency_dropdownFormField'),
      value: state.currency,
      items: Currency.values.map((currency) {
        return DropdownMenuItem<Currency>(
          value: currency,
          child: Text(currency.toString()),
        );
      }).toList(),
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editAccountTypeLabel,
        hintText: hintText,
      ),
      onChanged: (Currency? value) => context
          .read<AddPositionBloc>()
          .add(AddPositionCurrencyChanged(currency: value!)),
      validator: (Currency? value) {
        if (value == null) {
          return l10n.editAccountMissingType;
        }
        return null;
      },
    );
  }
}

class _TickerField extends StatelessWidget {
  const _TickerField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AddPositionBloc>().state;
    final hintText = state.initialPosition?.ticker ?? '';

    return TextFormField(
      key: const Key('AddPositionView_ticker_textFormField'),
      initialValue: state.ticker,
      decoration: InputDecoration(
        enabled: state.status != AddPositionStatus.success,
        labelText: l10n.addPositionTickerLabel,
        hintText: hintText,
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s.-]')),
      ],
      onChanged: (value) {
        context
            .read<AddPositionBloc>()
            .add(AddPositionTickerChanged(ticker: value));
      },
    );
  }
}

class _QtyOfSharesField extends StatelessWidget {
  const _QtyOfSharesField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AddPositionBloc>().state;
    final hintText = state.initialPosition?.qtyOfShares.toString() ?? '0';

    return TextFormField(
      key: const Key('AddPositionView_qtyOfShares_textFormField'),
      initialValue: state.qtyOfShares.toString(),
      decoration: InputDecoration(
        enabled: state.status != AddPositionStatus.success,
        labelText: l10n.addPositionQtyOfSharesLabel,
        hintText: hintText,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
      ],
      onChanged: (value) {
        context.read<AddPositionBloc>().add(
              AddPositionQtyOfSharesChanged(
                qtyOfShares: double.parse(value),
              ),
            );
      },
    );
  }
}

class _CostField extends StatelessWidget {
  const _CostField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AddPositionBloc>().state;
    final hintText = state.initialPosition?.cost.toString() ?? '0';

    return TextFormField(
      key: const Key('AddPositionView_cost_textFormField'),
      initialValue: state.cost.toString(),
      decoration: InputDecoration(
        enabled: state.status != AddPositionStatus.success,
        labelText: l10n.addPositionCostLabel,
        hintText: hintText,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
      ],
      onChanged: (value) {
        context.read<AddPositionBloc>().add(
              AddPositionCostChanged(
                cost: double.parse(value),
              ),
            );
      },
    );
  }
}
