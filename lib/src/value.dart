import 'package:flutter/foundation.dart';
import 'hashset_notifier.dart';

class Value<T> extends HashSetNotifier implements ValueListenable<T> {
  Value(this._value);

  T get value {
    notifyChildrens();
    return _value;
  }

  @override
  String toString() => value.toString();

  T _value;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    updater();
  }

  T call([T v]) {
    if (v != null) {
      this.value = v;
    }
    return this.value;
  }

  void update(void fn(T value)) {
    fn(value);
    updater();
  }
}

extension ReactiveT<T> on T {
  Value<T> get reactive => Value<T>(this);
}

typedef Condition = bool Function();
