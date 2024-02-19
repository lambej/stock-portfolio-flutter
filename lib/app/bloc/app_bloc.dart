import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_clipboard/authentication/authentication.dart';
import 'package:cloud_clipboard/text_clipboard/text_clipboard.dart';
import 'package:equatable/equatable.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({
    required AuthenticationRepository authenticationRepository,
    required ClipboardRepository clipboardRepository,
  })  : _authenticationRepository = authenticationRepository,
        _clipboardRepository = clipboardRepository,
        super(
          authenticationRepository.currentUser.isNotEmpty
              ? AppState.authenticated(authenticationRepository.currentUser)
              : const AppState.unauthenticated(),
        ) {
    on<_AppUserChanged>(_onUserChanged);
    on<AppLoaded>((event, emit) => emit(AppState.appLoaded(event.user)));
    on<AppLogoutRequested>(_onLogoutRequested);

    _userSubscription = _authenticationRepository.user.listen((user) {
      if (user.isNotEmpty) {
        _clipboardRepository
            .init(authenticationRepository.currentUser.id)
            .then((value) {
          add(AppLoaded(authenticationRepository.currentUser));
        });
      }
      add(_AppUserChanged(user));
    });
  }

  final AuthenticationRepository _authenticationRepository;
  final ClipboardRepository _clipboardRepository;

  late final StreamSubscription<User> _userSubscription;
  void _onUserChanged(_AppUserChanged event, Emitter<AppState> emit) {
    emit(
      event.user.isNotEmpty
          ? AppState.authenticated(event.user)
          : const AppState.unauthenticated(),
    );
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
