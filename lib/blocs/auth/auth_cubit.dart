import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/supabase_auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SupabaseAuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _init();
  }

  void _init() {
    _authRepository.authStateChanges.listen((data) {
      final Session? session = data.session;
      if (session != null) {
        emit(Authenticated(session.user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authRepository.signIn(email: email, password: password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _authRepository.signUp(email: email, password: password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
