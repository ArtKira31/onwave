import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  AuthState({required this.isAuthenticated});
}

class AuthNotifier extends AutoDisposeNotifier<AuthState> {
  @override
  AuthState build() => AuthState(isAuthenticated: false);

  void login() => state = AuthState(isAuthenticated: true);
  void logout() => state = AuthState(isAuthenticated: false);
}

final authProvider = AutoDisposeNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
