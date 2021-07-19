# Server Sent Events client package.

This package provides support for bi-directional communication through Server Sent Events and corresponding POST requests. It's platform-independent, and can be used on both the command-line and the browser.

## Usage

A simple usage example:

```dart
import 'package:sse_client/sse_client.dart';

void main() {
  var sseClient = SseClient.connect(Uri.parse('http://localhost:5000/stream?channel=messages'));
  var stream = sseClient.stream;
  if (stream == null) {
    print('Stream is not connected');
    return;
  }
  stream.listen((event) {
    print(event); // event is a String
  });                                   
}
```
