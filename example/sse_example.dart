import 'package:sse/sse.dart';

main() {
  var e = EventSource();
  e.connect(url: 'http://www.google.com');
}
