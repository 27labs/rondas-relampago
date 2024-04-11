import 'package:flutter/widgets.dart';

class RelampagoState<T extends Record> with ChangeNotifier {
  T? _state;
  RelampagoState(T state) : _state = state;

  T? get state => _state;
  set state(T? state) {
    _state = state;
  }

  void invalidate() => notifyListeners();
}

typedef StateUpdater = StateUpdaterNotification Function();

enum StateUpdaterNotification {
  done,
}
