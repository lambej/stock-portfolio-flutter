import 'package:cloud_clipboard/app/app.dart';
import 'package:cloud_clipboard/authentication/repository/authentication_repository.dart';
import 'package:cloud_clipboard/l10n/l10n.dart';
import 'package:cloud_clipboard/routes/routes.dart';
import 'package:cloud_clipboard/text_clipboard/repository/clipboard_repository.dart';
import 'package:cloud_clipboard/text_clipboard/text_clipboard.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({
    required ClipboardRepository clipboardRepository,
    required AuthenticationRepository authenticationRepository,
    super.key,
  })  : _clipboardRepository = clipboardRepository,
        _authenticationRepository = authenticationRepository;
  final ClipboardRepository _clipboardRepository;
  final AuthenticationRepository _authenticationRepository;
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ClipboardRepository>(
          create: (context) => _clipboardRepository,
        ),
        RepositoryProvider.value(
          value: _authenticationRepository,
        ),
      ],
      child: BlocProvider(
        create: (_) => AppBloc(
          authenticationRepository: _authenticationRepository,
          clipboardRepository: _clipboardRepository,
        ),
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            return MaterialApp(
              theme: ThemeData(
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color.fromARGB(255, 5, 142, 196),
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Color.fromARGB(255, 5, 142, 196),
                ),
                useMaterial3: true,
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: FlowBuilder<AppStatus>(
                state: context.select((AppBloc bloc) => bloc.state.status),
                onGeneratePages: onGenerateAppViewPages,
              ),
            );
          },
        ),
      ),
    );
  }
}
