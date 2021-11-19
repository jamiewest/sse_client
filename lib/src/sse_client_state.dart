abstract class SseClientState {
  SseClientState._();

  // Duplicating the state constants from EventSource so that user
  // does not have to import dart:html.
  static const int connecting = 0;
  static const int open = 1;
  static const int closed = 2;
}
