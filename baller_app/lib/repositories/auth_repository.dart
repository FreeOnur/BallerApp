import 'package:baller_app/repositories/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> signInWithEmailPassword(String email, String password);
  Future<AuthResult> signUp(String email, String password);
  Future<void> signOut();
  Future<bool> hasSession();
  String? getCurrentUserEmail();
  String? getCurrentUserId();
}
