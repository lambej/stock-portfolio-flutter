import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/account_types/edit_account_type/edit_account_type.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';
import 'package:stock_portfolio/shared/shared.dart';

class EditAccountTypePage extends StatelessWidget {
  const EditAccountTypePage({super.key});

  static Route<void> route({AccountType? initialAccountType}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => EditAccountTypeBloc(
          portfolioRepository: context.read<PortfolioRepository>(),
          initialAccountType: initialAccountType,
        ),
        child: const EditAccountTypePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<EditAccountTypeBloc, EditAccountTypeState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
                  current.status == EditAccountTypeStatus.success ||
              current.status == EditAccountTypeStatus.maxReached,
          listener: (context, state) => Navigator.of(context).pop(),
        ),
        BlocListener<EditAccountTypeBloc, EditAccountTypeState>(
          listener: (context, state) {
            if (state.status == EditAccountTypeStatus.maxReached) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  elevation: 5,
                  content: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)
                              .editAccountTypeMaxAccountTypeSnackBar,
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
      child: const EditAccountTypeView(),
    );
  }
}

class EditAccountTypeView extends StatelessWidget {
  const EditAccountTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status =
        context.select((EditAccountTypeBloc bloc) => bloc.state.status);
    final isNewAccountType = context.select(
      (EditAccountTypeBloc bloc) => bloc.state.isNewAccountType,
    );
    final theme = Theme.of(context);
    final floatingActionButtonTheme = theme.floatingActionButtonTheme;
    final fabBackgroundColor = floatingActionButtonTheme.backgroundColor ??
        theme.colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewAccountType
              ? l10n.editAccountTypeAddAppBarTitle
              : l10n.editAccountTypeEditAppBarTitle,
        ),
      ),
      floatingActionButton: Tooltip(
        message: l10n.editAccountTypeSaveButtonTooltip,
        child: MaterialButton(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          color: status.isLoadingOrSuccess
              ? fabBackgroundColor.withOpacity(0.5)
              : fabBackgroundColor,
          onPressed: status.isLoadingOrSuccess
              ? null
              : () => context
                  .read<EditAccountTypeBloc>()
                  .add(const EditAccountTypeSubmitted()),
          child: status.isLoadingOrSuccess
              ? const CupertinoActivityIndicator()
              : const Icon(Icons.check_rounded),
        ),
      ),
      body: const CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [_TypeField()],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeField extends StatelessWidget {
  const _TypeField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<EditAccountTypeBloc>().state;
    final hintText = state.initialAccountType?.type ?? '';

    return TextFormField(
      key: const Key('editAccountTypeView_type_textFormField'),
      initialValue: state.type,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editAccountTypeTypeLabel,
        hintText: hintText,
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
      ],
      onChanged: (value) {
        context
            .read<EditAccountTypeBloc>()
            .add(EditAccountTypeTypeChanged(value));
      },
    );
  }
}
