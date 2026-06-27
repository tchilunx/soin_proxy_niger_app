import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final isLoggedIn = await _authRepository.isLoggedIn();
    if (!isLoggedIn) {
      emit(const AuthState.unauthenticated());
      return;
    }

    final result = await _authRepository.getCurrentUser();
    final token = await _authRepository.getToken();

    result.fold(
      (failure) => emit(const AuthState.unauthenticated()),
      (user) => emit(AuthState.authenticated(user: user, token: token ?? '')),
    );
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (response) => emit(AuthState.authenticated(
        user: response.user,
        token: response.token,
      )),
    );
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.register(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
      phone: event.phone,
      role: event.role,
      profession: event.profession,
      licenseNumber: event.licenseNumber,
      pharmacyName: event.pharmacyName,
      address: event.address,
    );

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (response) => emit(AuthState.authenticated(
        user: response.user,
        token: response.token,
      )),
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.logout();

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }
}

