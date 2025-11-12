import 'package:alrahma/core/services/update_service.dart';
import 'package:alrahma/core/utils/print_statement.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:alrahma/app/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alrahma/core/utils/api_keys.dart';
import 'package:alrahma/core/utils/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: AppStrings.env);

  // setupDI();
  await Hive.initFlutter();
  // await Firebase.initializeApp();

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  // // ✅ راقب التحديثات
  // UpdateService.checkUpdates(
  //   onUpdate: (payload) {
  //     printHere("📢 Received update: $payload");
  //   },
  // );
  runApp(const Alrahma());
}
