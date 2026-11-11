import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<AuthState> authState() => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> register(String name, String email, String password) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    final user = res.user;
    if (user != null) {
      await _client.from('users').upsert({
        'id': user.id,
        'name': name,
        'email': email,
        'role': 'user',
      });
    }
    return res;
  }

  Future<AuthResponse> login(String email, String password) async {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() => _client.auth.signOut();

  Future<Map<String, dynamic>?> profile() async {
    final u = currentUser;
    if (u == null) return null;
    final res = await _client.from('users').select().eq('id', u.id).maybeSingle();
    return res;
  }
}
