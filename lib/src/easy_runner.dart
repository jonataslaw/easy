import 'package:flutter/foundation.dart';

class EasyRunner<T> implements _BaseEasyRunner {
  EasyRunner(this.observer, {VoidCallback onChange}) {
    _listener = onChange ?? run;
    _resolver = Tracker._(this);
  }

  final EasyRunCallback<T> observer;

  VoidCallback _listener;
  Tracker _resolver;

  void dispose() {
    _observe((_) {});
  }

  T run() {
    return _observe((Tracker resolver) => observer(resolver._, resolver.track));
  }

  T _observe<T>(T func(Tracker resolve)) {
    final next = Tracker._(this);
    try {
      return func(next);
    } finally {
      for (var item in _resolver._listenables.difference(next._listenables)) {
        item.removeListener(_listener);
      }
      _resolver = next;
    }
  }

  void _addListenable(Listenable listenable) {
    if (!_resolver._listenables.contains(listenable)) {
      listenable.addListener(_listener);
    }
  }
}

typedef R EasyRunCallback<R>(T Function<T>(ValueListenable<T> value) _,
    S Function<S extends Listenable>(S listenable) track);

EasyRunner<void> autoRun(EasyRunCallback observer, {VoidCallback onChange}) =>
    EasyRunner<void>(observer, onChange: onChange)..run();

abstract class _BaseEasyRunner {
  void _addListenable(Listenable listenable);
}

class Tracker {
  Tracker._(this._autoRunner);

  final _BaseEasyRunner _autoRunner;
  final _listenables = <Listenable>{};

  T call<T>(ValueListenable<T> listenable) => _(listenable);

  T _<T>(ValueListenable<T> listenable) => track(listenable).value;

  T track<T extends Listenable>(T listenable) {
    if (_listenables.add(listenable)) {
      _autoRunner._addListenable(listenable);
    }
    return listenable;
  }
}
