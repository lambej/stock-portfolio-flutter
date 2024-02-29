import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_portfolio/accounts/edit_account/edit_account.dart';
import 'package:stock_portfolio/l10n/l10n.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';
import 'package:stock_portfolio/shared/shared.dart';

class EditAccountPage extends StatelessWidget {
  const EditAccountPage({super.key});

  static Route<Account> route({Account? initialAccount}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => EditAccountBloc(
          portfolioRepository: context.read<PortfolioRepository>(),
          initialAccount: initialAccount,
        ),
        child: const EditAccountPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<EditAccountBloc, EditAccountState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == EditAccountStatus.success,
          listener: (context, state) => Navigator.of(context).pop(
            state.initialAccount?.copyWith(
              name: state.name,
              accountType: state.type,
              description: state.description,
            ),
          ),
        ),
        BlocListener<EditAccountBloc, EditAccountState>(
          listener: (context, state) {
            if (state.status == EditAccountStatus.maxReached) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  elevation: 5,
                  content: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)
                              .editAccountMaxAccountSnackBar,
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
      child: const EditAccountView(),
    );
  }
}

class EditAccountView extends StatelessWidget {
  const EditAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = context.select((EditAccountBloc bloc) => bloc.state.status);
    final isNewAccount = context.select(
      (EditAccountBloc bloc) => bloc.state.isNewAccount,
    );
    final theme = Theme.of(context);
    final floatingActionButtonTheme = theme.floatingActionButtonTheme;
    final fabBackgroundColor = floatingActionButtonTheme.backgroundColor ??
        theme.colorScheme.secondary;
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewAccount
              ? l10n.editAccountAddAppBarTitle
              : l10n.editAccountEditAppBarTitle,
        ),
      ),
      floatingActionButton: Tooltip(
        message: l10n.editAccountSaveButtonTooltip,
        child: MaterialButton(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          color: status.isLoadingOrSuccess
              ? fabBackgroundColor.withOpacity(0.5)
              : fabBackgroundColor,
          onPressed: status.isLoadingOrSuccess
              ? null
              : () {
                  if (formKey.currentState!.validate()) {
                    context
                        .read<EditAccountBloc>()
                        .add(const EditAccountSubmitted());
                  }
                },
          child: status.isLoadingOrSuccess
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
                children: [_TypeField(), _NameField(), _DescriptionField()],
              ),
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
    final state = context.watch<EditAccountBloc>().state;
    final hintText = state.initialAccount?.accountType?.type;

    return StreamBuilder<List<AccountType>>(
      stream: context.read<PortfolioRepository>().getAccountTypes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final isStateTypeExists = snapshot.data!
              .any((accountType) => accountType.id == state.type?.id);
          return DropdownButtonFormField<AccountType>(
            key: const Key('editAccountView_type_dropdownFormField'),
            value: isStateTypeExists ? state.type : null,
            items: snapshot.data!.map((accountType) {
              return DropdownMenuItem<AccountType>(
                value: accountType,
                child: Text(accountType.type),
              );
            }).toList(),
            decoration: InputDecoration(
              enabled: !state.status.isLoadingOrSuccess,
              labelText: l10n.editAccountTypeLabel,
              hintText: hintText,
            ),
            onChanged: (AccountType? value) => context
                .read<EditAccountBloc>()
                .add(EditAccountTypeChanged(value!)),
            validator: (AccountType? value) {
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

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<EditAccountBloc>().state;
    final hintText = state.initialAccount?.name ?? '';

    return TextFormField(
      key: const Key('editAccountView_name_textFormField'),
      initialValue: state.name,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editAccountNameLabel,
        hintText: hintText,
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
      ],
      onChanged: (value) {
        context.read<EditAccountBloc>().add(EditAccountNameChanged(value));
      },
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final state = context.watch<EditAccountBloc>().state;
    final hintText = state.initialAccount?.description ?? '';

    return TextFormField(
      key: const Key('editTodoView_description_textFormField'),
      initialValue: state.description,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editAccountDescriptionLabel,
        hintText: hintText,
      ),
      maxLength: 300,
      maxLines: 7,
      inputFormatters: [
        LengthLimitingTextInputFormatter(300),
      ],
      onChanged: (value) {
        context
            .read<EditAccountBloc>()
            .add(EditAccountDescriptionChanged(value));
      },
    );
  }
}
