import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:sse_client/src/event_source_transformer.dart';
import 'package:sse_client/src/sse_client.dart';

class SseClientException implements Exception {
  final String message;

  SseClientException(this.message);

  @override
  String toString() {
    return 'SseClientException: $message';
  }
}

class IOSseClient extends SseClient {
  IOSseClient(Stream stream) : super(stream: stream);

  factory IOSseClient.connect(Uri uri) {
    late StreamController<String?> incomingController;
    final client = ClientWithCustomExceptionType();

    incomingController = StreamController<String?>.broadcast(onListen: () {
      final request = Request('GET', uri)
        ..headers['Accept'] = 'text/event-stream';

      client.send(request).then((response) {
        if (response.statusCode == 200) {
          response.stream.transform(EventSourceTransformer()).listen((event) {
            incomingController.sink.add(event.data);
          });
        } else {
          incomingController.addError(
              SseClientException('Failed to connect to ${uri.toString()}'));
        }
      });
    }, onCancel: () {
      incomingController.close();
    });

    return IOSseClient(incomingController.stream);
  }
}

class ClientWithCustomExceptionType extends BaseClient {
  /// The underlying `dart:io` HTTP client.
  final HttpClient _inner;

  ClientWithCustomExceptionType([HttpClient? inner])
      : _inner = inner ?? HttpClient();

  /// Sends an HTTP request and asynchronously returns the response.
  @override
  Future<IOStreamedResponse> send(BaseRequest request) async {
    var stream = request.finalize();

    try {
      var ioRequest = (await _inner.openUrl(request.method, request.url))
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..contentLength = (request.contentLength ?? -1)
        ..persistentConnection = request.persistentConnection;
      request.headers.forEach((name, value) {
        ioRequest.headers.set(name, value);
      });

      var response = await stream.pipe(ioRequest) as HttpClientResponse;

      var headers = <String, String>{};
      response.headers.forEach((key, values) {
        headers[key] = values.join(',');
      });

      return IOStreamedResponse(
          response.handleError((error) {
            final httpException = error as HttpException;
            throw SseClientException('handleError: ${httpException.message}');
          }, test: (error) => error is HttpException),
          response.statusCode,
          contentLength:
              response.contentLength == -1 ? null : response.contentLength,
          request: request,
          headers: headers,
          isRedirect: response.isRedirect,
          persistentConnection: response.persistentConnection,
          reasonPhrase: response.reasonPhrase,
          inner: response);
    } on HttpException catch (error) {
      throw SseClientException('HttpException: ${error.message}');
    } catch (e) {
      throw SseClientException('Exception: type: ${e.runtimeType}, e = $e');
    }
  }

  /// Closes the client.
  ///
  /// Terminates all active connections. If a client remains unclosed, the Dart
  /// process may not terminate.
  @override
  void close() {
    _inner.close(force: true);
  }
}
