import 'dart:async';

// ignore: uri_does_not_exist
import 'client_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'sse_browser_client.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'sse_io_client.dart';

typedef OnOpen = void Function();

abstract class EventSource {
  factory EventSource() => createEventSource();

  OnOpen onopen;

  /// Add messages to this [StreamSink] to send them to the server.
  ///
  /// The message added to the sink has to be JSON encodable. Messages that fail
  /// to encode will be logged through a [Logger].
  StreamSink<String> get sink;

  /// [Stream] of messages sent from the server to this client.
  ///
  /// A message is a decoded JSON object.
  Stream<String> get stream;

  void connect({String url});

  void close();
}