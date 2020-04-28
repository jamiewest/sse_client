import 'dart:async';

// ignore: uri_does_not_exist
import '_connect_api.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) '_connect_html.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) '_connect_io.dart' as platform;

/// A client for sse communcation.
class SseClient {
  SseClient({this.stream});

  /// Creates a new server sent events connection.
  ///
  /// Connects to [uri] using and returns a stream that can be used to
  /// sends events in `text/event-stream` format.
  factory SseClient.connect(Uri uri) => platform.connect(uri);

  final Stream stream;
}
