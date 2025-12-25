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

  Future<void> signIn(String identifier, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signIn(identifier: identifier, password: password);
    } catch (e) {
      emit(AuthError(_getErrorMessage(e)));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username, // New
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
        username: username,
        gender: gender,
        age: age,
        city: city,
        country: country,
      );
      emit(Unauthenticated()); // Clear loading state
    } catch (e) {
      emit(AuthError(_getErrorMessage(e)));
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
      emit(AuthError(_getErrorMessage(e)));
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
      emit(AuthError(_getErrorMessage(e)));
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      if (error.message.contains('Invalid login credentials')) {
        return 'E-posta veya şifre hatalı.';
      } else if (error.message.contains('User already registered')) {
        return 'Bu e-posta adresi zaten kayıtlı.';
      } else if (error.message.contains('Password should be')) {
        return 'Şifre çok zayıf. En az 6 karakter kullanın.';
      } else if (error.message.contains('Email not confirmed')) {
        return 'Lütfen e-posta adresinizi doğrulayın.';
      } else if (error.message.contains('Kullanıcı adı bulunamadı')) {
        return 'Kullanıcı adı bulunamadı.';
      }
    }
    // Fallback for other errors (simplified)
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }
}
