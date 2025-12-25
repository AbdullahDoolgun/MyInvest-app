import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<void> signIn({
    required String identifier,
    required String password,
  }) async {
    String emailToUse = identifier;

    // Check if identifier is NOT an email (simple check)
    final bool isEmail = identifier.contains('@');

    if (!isEmail) {
      // It's a username, fetch the email
      try {
        final data = await _supabase.rpc(
          'get_email_by_username',
          params: {'username_input': identifier},
        );

        if (data != null) {
          emailToUse = data as String;
        } else {
          throw const AuthException("Kullanıcı adı bulunamadı.");
        }
      } catch (e) {
        // If profile lookup fails or table doesn't exist yet, we can't proceed with username
        if (e is AuthException) rethrow;
        throw Exception("Giriş yapılırken hata oluştu: $e");
      }
    }

    await _supabase.auth.signInWithPassword(
      email: emailToUse,
      password: password,
    );
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
    // 1. Create Auth User
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'username': username, // Store in metadata too
        'gender': gender,
        'age': age,
        'city': city,
        'country': country,
      },
    );

    // Profile creation is now handled by a Database Trigger on auth.users
    // avoiding RLS issues during sign up.
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

      // Update profiles table if needed (simplified mapping)
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final profileUpdates = <String, dynamic>{};
        if (firstName != null || lastName != null) {
          // We'd need current names to construct full name properly if only one changes,
          // but for now let's just update what we have if strictly set
          // Or better, just ignore full_name update here for simplicity unless crucial
        }
        if (age != null) profileUpdates['age'] = age;
        if (city != null) profileUpdates['city'] = city;
        if (country != null) profileUpdates['country'] = country;
        if (gender != null) profileUpdates['gender'] = gender;

        if (profileUpdates.isNotEmpty) {
          profileUpdates['updated_at'] = DateTime.now().toIso8601String();
          await _supabase
              .from('profiles')
              .update(profileUpdates)
              .eq('id', user.id);
        }
      }
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
