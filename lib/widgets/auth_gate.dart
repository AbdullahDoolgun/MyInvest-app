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
        if (state is Authenticated) {
          return const MainScreen(); // MainScreen likely exists based on file list
        } else if (state is Unauthenticated) {
          return const LoginScreen();
        } 
        
        // Show loading or splash while initializing
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
