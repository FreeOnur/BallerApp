import 'package:baller_app/core/config/app_config.dart';
import 'package:baller_app/repositories/api_auth_repository.dart';
import 'package:baller_app/repositories/auth_repository.dart';
import 'package:baller_app/repositories/court_repository.dart';
import 'package:baller_app/repositories/profile_repository.dart';
import 'package:baller_app/repositories/supabase_auth_repository.dart';

class RepositoryProvider {
  RepositoryProvider._();

  static final AuthRepository auth = AppConfig.useLegacySupabase
      ? SupabaseAuthRepository()
      : ApiAuthRepository();

  static final ProfileRepository profiles = ProfileRepository();
  static final CourtRepository courts = CourtRepository();
}
