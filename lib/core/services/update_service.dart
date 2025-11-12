import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static RealtimeChannel? _channel;
  static bool _isListening = false;

  /// start listening to broadcasts on channel 'app_updates'
  static void checkUpdates({void Function(Map<String, dynamic>)? onUpdate}) {
    if (_isListening) return;
    _isListening = true;

    _channel = _supabase.channel('app_updates');

    // Try the simple broadcast handler first — if your library requires different API
    // replace with the channel.on('broadcast', ChannelFilter(...), callback) variant.
    _channel!.onBroadcast(
      event: 'update',
      callback: (payload) {
        debugPrint("🔥 Update Broadcast Received: $payload");

        // payload from realtime.send / broadcast might be a Map or JSON string.
        Map<String, dynamic> data;
        if (payload is String) {
          try {
            data = jsonDecode(payload as String) as Map<String, dynamic>;
          } catch (_) {
            data = {'raw': payload};
          }
        } else {
          data = payload;
        }

        if (onUpdate != null) onUpdate(data);
      },
    );

    _channel!.subscribe();
    debugPrint("✅ UpdateService is now listening for updates...");
  }

  /// call when you want to stop listening (e.g., on app dispose)
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
