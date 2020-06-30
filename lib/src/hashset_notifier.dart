import 'dart:collection';
import 'package:flutter/foundation.dart';

class HashSetNotifier implements Listenable {
  HashSet<VoidCallback> _listeners = HashSet<VoidCallback>();

  void updater() {
    assert(_debugAssertNotDisposed());
    if (_listeners != null) {
      _listeners.forEach((element) {
        element();
      });
    }
  }

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_listeners == null) {
        throw FlutterError('A $runtimeType was used after being disposed.\n'
            'Once you have called dispose() on a $runtimeType, it can no longer be used.');
      }
      return true;
    }());
    return true;
  }

  bool get hasListeners {
    assert(_debugAssertNotDisposed());
    return _listeners.isNotEmpty;
  }

  @override
  void addListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _listeners.remove(listener);
  }

  @mustCallSuper
  void dispose() {
    assert(_debugAssertNotDisposed());
    _listeners = null;
  }
}
