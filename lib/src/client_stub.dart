import 'base_event_source.dart';

/// Implemented in `browser_client.dart` and `io_client.dart`.
BaseEventSource createEventSource() => throw UnsupportedError(
    'Cannot create a client without dart:html or dart:io.');