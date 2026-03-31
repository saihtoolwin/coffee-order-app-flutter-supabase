import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final data = await _supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    return data;
  }

  Future<Map<String, dynamic>> register({
    required String phone,
    required String name,
    String? email,
  }) async {
    final phoneWithCode = phone.startsWith('+') ? phone : '+$phone';

    final existingUser = await _supabase
        .from('users')
        .select()
        .eq('phone', phoneWithCode)
        .maybeSingle();

    if (existingUser != null) {
      return existingUser;
    }

    final userData = await _supabase
        .from('users')
        .insert({
          'phone': phoneWithCode,
          'name': name,
          'email': email,
          'role': 'customer',
        })
        .select()
        .single();

    return userData;
  }

  Future<Map<String, dynamic>?> login({required String phone}) async {
    final phoneWithCode = phone.startsWith('+') ? phone : '+$phone';

    final user = await _supabase
        .from('users')
        .select()
        .eq('phone', phoneWithCode)
        .maybeSingle();

    return user;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await _supabase.auth.signOut();
  }

  bool get isLoggedIn => _supabase.auth.currentUser != null;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
