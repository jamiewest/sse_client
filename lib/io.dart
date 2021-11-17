import 'dart:async';

import 'package:http/http.dart';
import 'package:sse_client/src/event_source_transformer.dart';
import 'package:sse_client/src/sse_client.dart';

class IOSseClient extends SseClient {
  @override
  final Stream<String?> stream;

  IOSseClient(this.stream);

  factory IOSseClient.connect(Uri uri) {
    late StreamController<String?> incomingController;
    final client = Client();

    incomingController = StreamController<String?>.broadcast(onListen: () {
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

  @override
  void close() {
    // TODO
    throw UnimplementedError();
  }

  @override
  // TODO: implement errors
  Stream<void> get errorEvents => throw UnimplementedError();

  @override
  // TODO: implement
  Stream<void> get openEvents => throw UnimplementedError();

  @override
  // TODO: implement
  int? get readyState => throw UnimplementedError();
}
