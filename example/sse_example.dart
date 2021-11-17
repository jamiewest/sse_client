import 'package:sse_client/sse_client.dart';

void main() {
  final sseClient = SseClient.connect(Uri.parse('http://localhost:5000/stream?channel=messages'));

  sseClient.stream.listen((String? event) {
    print(event);
  });                                   
}
