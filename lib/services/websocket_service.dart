import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Function(dynamic)? onData;

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(AppConstants.wsUrl));
    _channel!.stream.listen((message) {
      if (onData != null) {
        onData!(jsonDecode(message));
      }
    }, onError: (err) {
      debugPrint('WS Error: $err');
      // Reconnect logic here
    }, onDone: () {
      debugPrint('WS Closed');
    });
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
