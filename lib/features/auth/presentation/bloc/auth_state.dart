import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.errorMessage,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);

  const AuthState.loading() : this(status: AuthStatus.loading);

  const AuthState.authenticated({
    required User user,
    required String token,
  }) : this(
          status: AuthStatus.authenticated,
          user: user,
          token: token,
        );

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  const AuthState.error(String message)
      : this(status: AuthStatus.error, errorMessage: message);

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isPatient => user?.isPatient ?? false;
  bool get isMedicalProfessional => user?.isMedicalProfessional ?? false;
  bool get isPharmacist => user?.isPharmacist ?? false;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, token, errorMessage];
}

