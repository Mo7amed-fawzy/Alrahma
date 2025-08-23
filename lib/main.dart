import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tabea/app/app.dart';
// import 'package:tabea/core/services/app_dependencies.dart';
// import 'package:tabea/core/utils/api_keys.dart';
// import 'package:tabea/core/utils/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await dotenv.load(fileName: AppStrings.env);

  // setupDI();
  await Hive.initFlutter();

  // await Supabase.initialize(
  //   url: EnvConfig.supabaseUrl,
  //   anonKey: EnvConfig.supabaseAnonKey,
  // );
  runApp(const Tabea());
}
