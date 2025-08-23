import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class EnvConfig {
  static final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static final String supabasePass = dotenv.env['DATABASE_PASSWORD'] ?? '';
  static final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static final String supabaseServiceKey =
      dotenv.env['SUPABASE_SERVICE_KEY'] ?? '';
}
