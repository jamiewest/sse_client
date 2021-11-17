import 'dart:async';
import 'dart:html';

import 'package:sse_client/src/sse_client.dart';

class HtmlSseClient extends SseClient {
  final Uri uri;
  final bool withCredentials;
  final EventSource eventSource;

  final _messageController = StreamController<String?>.broadcast();
  @override
  Stream<String?> get stream => _messageController.stream;

  final _errorController = StreamController<void>.broadcast();
  @override
  Stream<void> get errorEvents => _errorController.stream;

  final _openController = StreamController<void>.broadcast();
  @override
  Stream<void> get openEvents => _openController.stream;

  @override
  int? get readyState => eventSource.readyState;

  HtmlSseClient({
    required this.uri,
    this.withCredentials = false,
  }) :
      eventSource = EventSource(uri.toString(), withCredentials: withCredentials)
  {
    eventSource.addEventListener('message', (Event message) {
      _messageController.add((message as MessageEvent).data as String?);
    });

    eventSource.addEventListener('error', (Event message) {
      _errorController.add(message);
    });

    eventSource.addEventListener('open', (Event message) {
      _openController.add(message);
    });
  }

  @override
  void close() {
    eventSource.close();
    _messageController.close();
    _errorController.close();
    _openController.close();
  }
}
