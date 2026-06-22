import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

final supabaseClient = Supabase.instance.client;

class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final session = supabaseClient.auth.currentSession;
    if (session == null) return null;
    
    final profile = await _fetchProfile(session.user.id);
    if (profile == null) {
      // User is authenticated via Google but has no profile yet!
      return AppUser(
        id: session.user.id,
        role: 'pending_role',
        fullName: session.user.userMetadata?['full_name'] ?? 'Google User',
        email: session.user.email ?? '',
      );
    }
    return profile;
  }

  Future<AppUser?> _fetchProfile(String uid) async {
    try {
      final response = await supabaseClient.from('profiles').select().eq('id', uid).maybeSingle();
      if (response == null) return null;
      return AppUser.fromJson(response);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        final profile = await _fetchProfile(response.user!.id);
        state = AsyncValue.data(profile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  AppUser? _pendingGoogleUser;
  AppUser? get pendingGoogleUser => _pendingGoogleUser;
  String? _pendingGooglePassword;

  Future<bool> loginWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final success = await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
      );
      return success;
    } catch (e, stack) {
      print('Google Login Error: $e');
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<void> completeGoogleRegistration(String role) async {
    final session = supabaseClient.auth.currentSession;
    if (session == null) return;

    state = const AsyncValue.loading();
    try {
      final uid = session.user.id;
      final email = session.user.email ?? '';
      final fullName = session.user.userMetadata?['full_name'] ?? 'Google User';

      // Insert into profiles
      await supabaseClient.from('profiles').insert({
        'id': uid,
        'email': email,
        'full_name': fullName,
        'role': role,
      });

      // If chef, also create a dummy kitchen
      if (role == 'chef') {
        await supabaseClient.from('kitchens').insert({
          'chef_id': uid,
          'name': "$fullName's Kitchen",
          'is_open': true,
        });
      }

      final profile = await _fetchProfile(uid);
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> register(String email, String password, String fullName, String role) async {
    state = const AsyncValue.loading();
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Insert into profiles
        await supabaseClient.from('profiles').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'role': role,
        });

        // If chef, also create a dummy kitchen
        if (role == 'chef') {
          await supabaseClient.from('kitchens').insert({
            'chef_id': response.user!.id,
            'name': "$fullName's Kitchen",
            'is_open': true,
          });
        }

        final profile = await _fetchProfile(response.user!.id);
        state = AsyncValue.data(profile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await supabaseClient.auth.signOut();
    state = const AsyncValue.data(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(() {
  return AuthNotifier();
});
