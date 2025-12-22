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
    // Check initial session immediately
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      emit(Authenticated(currentUser));
    } else {
      emit(Unauthenticated());
    }

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
    emit(AuthLoading());
    try {
      await _authRepository.signIn(email: email, password: password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    required int age,
    required String city,
    required String country,
  }) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        age: age,
        city: city,
        country: country,
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    String? city,
    String? country,
  }) async {
    try {
      await _authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        age: age,
        city: city,
        country: country,
      );
      // Refresh user state
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        emit(Authenticated(currentUser));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    emit(AuthLoading());
    try {
      await _authRepository.updatePassword(newPassword);
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        emit(Authenticated(currentUser));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
