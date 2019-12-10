import 'dart:async';
import 'dart:convert';

import 'base_event_source.dart';
import 'package:http/http.dart';

BaseEventSource createEventSource() => ServerSentEventsIOClient();

class ServerSentEventsIOClient extends BaseEventSource  {
  var _incomingController = StreamController<String>();

  final _outgoingController = StreamController<String>();

  String _lastEventId;

  String _url;

  BaseClient _client;

  Future<void> startFuture;

  ServerSentEventsIOClient();
  
  @override
  StreamSink<String> get sink =>  _outgoingController.sink;

  @override
  Stream<String> get stream => _incomingController.stream;

  @override
  void connect({String url}) {
    _url = url;
    _client = Client();

    _outgoingController.stream
        .listen(_onOutgoingMessage, onDone: _onOutgoingDone);

    _incomingController = StreamController.broadcast(
      onListen: () {
        startFuture = _connect();
      },
      onCancel: () {
        close();
      },
    );

    _startPostingMessages();
  }

  Future<void> _connect() async {
    final headers = {};
    headers['Accept'] = 'text/event-stream';

    if (_lastEventId != null) {
      headers['Last-Event-ID'] = _lastEventId;
    }

    var request = Request('GET', Uri.parse(_url))
      ..headers['Accept'] = 'text/event-stream';
    final response = await _client.send(request);    

    if (response.statusCode == 200) {
      onopen();
    }

    response.stream.transform(EventSourceDecoder()).listen((data) {
      _onMessage(data);
    });
  }

  void _onMessage(Event message) {
    _incomingController.sink.add(message.data);
  }

  void _onOutgoingDone() {
    close();
  }

  final _messages = StreamController<dynamic>();

  void _onOutgoingMessage(dynamic message) async {
    _messages.add(message);
  }

  void _startPostingMessages() async {
    await for (var message in _messages.stream) {
      try {
        await _client.post(_url, body: message);
      } catch (e) {

      }
    }
  }

  @override
  void close() {
    _incomingController.close();
    _outgoingController.close();
  }

  @override
  var onopen;
}

class Event implements Comparable<Event> {
  /// An identifier that can be used to allow a client to replay
  /// missed Events by returning the Last-Event-Id header.
  /// Return empty string if not required.
  String id;

  /// The name of the event. Return empty string if not required.
  String event;

  /// The payload of the event.
  String data;

  Event({this.id, this.event, this.data});

  Event.message({this.id, this.data}) : event = 'message';

  @override
  int compareTo(Event other) => id.compareTo(other.id);
}


typedef RetryIndicator = void Function(Duration retry);

class EventSourceDecoder implements StreamTransformer<List<int>, Event> {
  RetryIndicator retryIndicator;

  EventSourceDecoder({this.retryIndicator});

  @override
  Stream<Event> bind(Stream<List<int>> stream) {
    StreamController<Event> controller;
    controller = StreamController(onListen: () {
      // the event we are currently building
      var currentEvent = Event();
      // the regexes we will use later
      var lineRegex = RegExp(r'^([^:]*)(?::)?(?: )?(.*)?$');
      var removeEndingNewlineRegex = RegExp(r'^((?:.|\n)*)\n$');
      // This stream will receive chunks of data that is not necessarily a
      // single event. So we build events on the fly and broadcast the event as
      // soon as we encounter a double newline, then we start a new one.
      stream
          .transform(Utf8Decoder())
          .transform(LineSplitter())
          .listen((String line) {
        if (line.isEmpty) {
          // event is done
          // strip ending newline from data
          if (currentEvent.data != null) {
            var match = removeEndingNewlineRegex.firstMatch(currentEvent.data);
            currentEvent.data = match.group(1);
          }
          controller.add(currentEvent);
          currentEvent = Event();
          return;
        }
        // match the line prefix and the value using the regex
        Match match = lineRegex.firstMatch(line);
        var field = match.group(1);
        var value = match.group(2) ?? '';
        if (field.isEmpty) {
          // lines starting with a colon are to be ignored
          return;
        }
        switch (field) {
          case 'event':
            currentEvent.event = value;
            break;
          case 'data':
            currentEvent.data = (currentEvent.data ?? "") + value + "\n";
            break;
          case 'id':
            currentEvent.id = value;
            break;
          case 'retry':
            if (retryIndicator != null) {
              retryIndicator(Duration(milliseconds: int.parse(value)));
            }
            break;
        }
      });
    });
    return controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast <RS, RT>() => StreamTransformer.castFrom<List<int>, Event, RS, RT>(this);
}