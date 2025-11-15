import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static RealtimeChannel? _channel;
  static bool _isListening = false;

  /// Start listening to INSERT events on "updates" table
  static void checkUpdates({void Function(Map<String, dynamic>)? onUpdate}) {
    if (_isListening) return;
    _isListening = true;

    // إنشاء قناة
    _channel = _supabase.channel('public:updates');

    // استماع لتغيرات الـ Postgres
    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'updates',
          callback: (payload) {
            try {
              // payload.newRecord يحتوي على السطر الجديد
              final newRow = payload.newRecord != null
                  ? Map<String, dynamic>.from(payload.newRecord!)
                  : {'raw': payload.toString()};

              debugPrint('🔥 Realtime update event: $newRow');
              if (onUpdate != null) onUpdate(newRow);
            } catch (e, st) {
              debugPrint('Error handling realtime payload: $e\n$st');
            }
          },
        )
        .subscribe();

    debugPrint(
      "✅ UpdateService is now listening for DB changes on 'updates'...",
    );
  }

  static void stopListening() {
    if (!_isListening) return;
    try {
      _channel?.unsubscribe();
    } catch (_) {}
    _channel = null;
    _isListening = false;
    debugPrint("🛑 UpdateService stopped listening.");
  }
}
