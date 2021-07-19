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
