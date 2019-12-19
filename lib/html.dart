import 'dart:async';
import 'dart:html';

import 'package:sse_client/src/sse_client.dart';

class HtmlSseClient extends SseClient {

  HtmlSseClient(Stream stream) : super(stream: stream);

  factory HtmlSseClient.connect(Uri uri, {bool withCredentials = false}) {
    final incomingController = StreamController<String>();
    final eventSource = EventSource(uri.toString(), withCredentials: withCredentials);
    
    eventSource.addEventListener('message', (Event message) {
      incomingController.add((message as MessageEvent).data as String);
    });

    return HtmlSseClient(incomingController.stream);
  }
}