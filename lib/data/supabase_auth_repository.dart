import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<void> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
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
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'age': age,
        'city': city,
        'country': country,
      },
    );
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    String? city,
    String? country,
  }) async {
    final updates = <String, dynamic>{};
    if (firstName != null) updates['first_name'] = firstName;
    if (lastName != null) updates['last_name'] = lastName;
    if (gender != null) updates['gender'] = gender;
    if (age != null) updates['age'] = age;
    if (city != null) updates['city'] = city;
    if (country != null) updates['country'] = country;

    if (updates.isNotEmpty) {
      await _supabase.auth.updateUser(UserAttributes(data: updates));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
