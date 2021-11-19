import 'dart:async';

// ignore: uri_does_not_exist
import '_connect_api.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) '_connect_html.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) '_connect_io.dart' as platform;

export 'sse_client_state.dart';

/// A client for sse communication.
abstract class SseClient {
  SseClient();

  /// Creates a new server sent events connection.
  ///
  /// Connects to [uri] using and returns a stream that can be used to
  /// sends events in `text/event-stream` format.
  factory SseClient.connect(Uri uri) => platform.connect(uri);

  Stream<String?> get stream;
  Stream<void> get errorEvents;
  Stream<void> get openEvents;
  int? get readyState;

  void close();
}
