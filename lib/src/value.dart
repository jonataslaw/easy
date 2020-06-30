import 'package:flutter/foundation.dart';
import 'package:easy/src/hashset_notifier.dart';

class Value<T> extends HashSetNotifier implements ValueListenable<T> {
  Value(this._value);

  @override
  T get value => _value;
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

  @override
  String toString() => '${describeIdentity(this)}($value)';
}

extension ReactiveT<T> on T {
  Value<T> get reactive => Value<T>(this);
}
