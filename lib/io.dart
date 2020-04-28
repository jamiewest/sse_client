import 'dart:async';

import 'package:http/http.dart';
import 'package:sse_client/src/event_source_transformer.dart';
import 'package:sse_client/src/sse_client.dart';

class IOSseClient extends SseClient {
  IOSseClient(Stream stream) : super(stream: stream);

  factory IOSseClient.connect(Uri uri) {
    StreamController<String> incomingController;
    final client = Client();

    incomingController = StreamController<String>.broadcast(onListen: () {
      var request = Request('GET', uri)
        ..headers['Accept'] = 'text/event-stream';

      client.send(request).then((response) {
        if (response.statusCode == 200) {
          response.stream.transform(EventSourceTransformer()).listen((event) {
            incomingController.sink.add(event.data);
          });
        } else {
          incomingController
              .addError(Exception('Failed to connect to ${uri.toString()}'));
        }
      });
    }, onCancel: () {
      incomingController.close();
    });

    return IOSseClient(incomingController.stream);
  }
}
