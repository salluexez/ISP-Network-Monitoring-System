import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/config/app_config.dart';

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return RealtimeService();
});

class RealtimeService {
  WebSocketChannel? _channel;

  Stream<dynamic> connect({required String token}) {
    final uri = Uri.parse(
      AppConfig.websocketUrl,
    ).replace(queryParameters: {'token': token});
    _channel = WebSocketChannel.connect(uri);
    return _channel!.stream;
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }
}
