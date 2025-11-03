import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static bool _isListening = false;

  static void checkUpdates({void Function(Map<String, dynamic>)? onUpdate}) {
    if (_isListening) return;
    _isListening = true;

    final channel = _supabase.channel('app_updates');

    channel.onBroadcast(
      event: 'update', // اسم الحدث اللي بتبعت بيه من SQL
      callback: (payload) {
        debugPrint("🔥 Update Broadcast Received: $payload");

        if (onUpdate != null) {
          onUpdate(payload);
        }
      },
    );

    channel.subscribe();

    debugPrint("✅ UpdateService is now listening for updates...");
  }
}
