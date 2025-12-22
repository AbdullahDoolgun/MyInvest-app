import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_cubit.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is Authenticated) {
          return const MainScreen();
        }
        // Unauthenticated, AuthError, AuthLoading (during login)
        return const LoginScreen();
      },
    );
  }
}
