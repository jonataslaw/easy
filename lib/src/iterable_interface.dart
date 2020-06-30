import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:easy/src/hashset_notifier.dart';

abstract class IterableInterface<S, T> extends HashSetNotifier
    implements ValueListenable<S> {
  HashSet<IterableListener> _iterablesListeners = HashSet<IterableListener>();

  void addIterableListener(IterableListener<T> listener) {
    _iterablesListeners.add(listener);
  }

  void removeIterableListener(IterableListener<T> listener) {
    _iterablesListeners.remove(listener);
  }

  @override
  void dispose() {
    super.dispose();
    _iterablesListeners = null;
  }

  @override
  @protected
  bool get hasListeners {
    return _iterablesListeners.isNotEmpty || super.hasListeners;
  }

  @protected
  void notify(T change) {
    updater();
    final list = List<IterableListener<T>>.from(_iterablesListeners);
    for (void Function(T) listener in list) {
      if (_iterablesListeners.contains(listener)) {
        listener(change);
      }
    }
  }
}

typedef IterableListener<T> = void Function(T);
