import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/positions/edit_position/edit_position.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';
import 'package:stock_portfolio/shared/shared.dart';

class EditPositionPage extends StatelessWidget {
  const EditPositionPage({super.key});

  static Route<Position> route({Position? initialPosition}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => EditPositionBloc(
          portfolioRepository: context.read<PortfolioRepository>(),
          initialPosition: initialPosition,
        ),
        child: const EditPositionPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<EditPositionBloc, EditPositionState>(
          listenWhen: (previous, current) =>
              current.status != previous.status &&
              current.status == EditPositionStatus.success,
          listener: (context, state) => Navigator.of(context).pop(
            state.initialPosition?.copyWith(
              ticker: state.ticker,
              qtyOfShares: state.qtyOfShares,
              cost: state.cost,
            ),
          ),
        ),
        BlocListener<EditPositionBloc, EditPositionState>(
          listener: (context, state) {
            if (state is EditPositionMaxReached) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  elevation: 5,
                  content: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)
                              .editPositionMaxPositionSnackBar,
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
      child: const EditPositionView(),
    );
  }
}

class EditPositionView extends StatelessWidget {
  const EditPositionView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isSuccess = context.select((EditPositionBloc bloc) =>
        bloc.state.status == EditPositionStatus.success);
    final isNewPosition = context.select(
      (EditPositionBloc bloc) => bloc.state.isNewPosition,
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
              ? l10n.editPositionAddAppBarTitle
              : l10n.editPositionEditAppBarTitle,
        ),
      ),
      floatingActionButton: Tooltip(
        message: l10n.editPositionSaveButtonTooltip,
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
                        .read<EditPositionBloc>()
                        .add(const EditPositionSubmitted());
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
                  _QtyOfSharesField()
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
    final state = context.watch<EditPositionBloc>().state;
    final hintText = state.initialPosition?.account?.name;

    return StreamBuilder<List<Account>>(
      stream: context.read<PortfolioRepository>().getAccounts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final isStateTypeExists =
              snapshot.data!.any((account) => account.id == state.account?.id);
          return DropdownButtonFormField<Account>(
            key: const Key('editPositionView_account_dropdownFormField'),
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
                .read<EditPositionBloc>()
                .add(EditPositionAccountChanged(account: value!)),
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

class _TickerField extends StatelessWidget {
  const _TickerField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<EditPositionBloc>().state;
    final hintText = state.initialPosition?.ticker ?? '';

    return TextFormField(
      key: const Key('editPositionView_ticker_textFormField'),
      initialValue: state.ticker,
      decoration: InputDecoration(
        enabled: state.status != EditPositionStatus.success,
        labelText: l10n.editPositionTickerLabel,
        hintText: hintText,
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
      ],
      onChanged: (value) {
        context
            .read<EditPositionBloc>()
            .add(EditPositionTickerChanged(ticker: value));
      },
    );
  }
}

class _QtyOfSharesField extends StatelessWidget {
  const _QtyOfSharesField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<EditPositionBloc>().state;
    final hintText = state.initialPosition?.qtyOfShares.toString() ?? '0';

    return TextFormField(
      key: const Key('editPositionView_qtyOfShares_textFormField'),
      initialValue: state.qtyOfShares.toString(),
      decoration: InputDecoration(
        enabled: state.status != EditPositionStatus.success,
        labelText: l10n.editPositionQtyOfSharesLabel,
        hintText: hintText,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (value) {
        context.read<EditPositionBloc>().add(
              EditPositionQtyOfSharesChanged(
                qtyOfShares: double.parse(value),
              ),
            );
      },
    );
  }
}
