import 'package:sse_client/io.dart';
import 'package:sse_client/src/sse_client.dart';

SseClient connect(Uri uri) => IOSseClient.connect(uri);
