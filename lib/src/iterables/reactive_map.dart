import 'dart:async';
import 'dart:collection';

import '../hashset_notifier.dart';
import '../value.dart';

class RxMap<K, V> extends HashSetNotifier implements Map<K, V> {
  RxMap([Map<K, V> initial]) {
    if (initial != null) _value = initial;
  }

  Map<K, V> _value;

  StreamController<Map<K, V>> subject;

  HashMap<Stream<Map<K, V>>, StreamSubscription> _subscriptions;

  Map<K, V> get value {
    notifyChildrens();
    return _value;
  }

  Map<K, V> call([Map<K, V> v]) {
    if (v != null) {
      this.value = v;
    }
    return this.value;
  }

  void refresh() {
    updater();
    if (subject != null) {
      subject.add(_value);
    }
  }

  Stream<Map<K, V>> get stream {
    subject ??= StreamController<Map<K, V>>.broadcast();
    return subject.stream;
  }

  /// Binds an existing [Stream<List>] to this [RxList].
  /// You can bind multiple sources to update the value.
  /// Closing the subscription will happen automatically when the observer
  /// Widget ([GetX] or [Obx]) gets unmounted from the Widget tree.
  void bindStream(Stream<Map<K, V>> stream) {
    _subscriptions[stream] = stream.listen((va) => value = va);
  }

  ///TODO fazer isso ser chamado pelo dispose
  void close() {
    if (_subscriptions != null) {
      _subscriptions.forEach((observable, subscription) {
        subscription.cancel();
      });
      _subscriptions.clear();
    }
    subject?.close();
  }

  String get string => value.toString();

  set value(Map<K, V> val) {
    if (_value == val) return;
    _value = val;
    refresh();
  }

  StreamSubscription<Map<K, V>> listen(void Function(Map<K, V>) onData,
          {Function onError, void Function() onDone, bool cancelOnError}) =>
      stream.listen(onData, onError: onError, onDone: onDone);

  void add(K key, V value) {
    _value[key] = value;
    refresh();
  }

  void addIf(dynamic condition, K key, V value) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) {
      _value[key] = value;
      refresh();
    }
  }

  void addAllIf(dynamic condition, Map<K, V> values) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) addAll(values);
  }

  @override
  V operator [](Object key) {
    return value[key];
  }

  @override
  void operator []=(K key, V value) {
    _value[key] = value;
    refresh();
  }

  @override
  void addAll(Map<K, V> other) {
    _value.addAll(other);
    refresh();
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    _value.addEntries(entries);
    refresh();
  }

  @override
  String toString() => value.toString();

  @override
  void clear() {
    _value.clear();
    refresh();
  }

  @override
  Map<K2, V2> cast<K2, V2>() => value.cast<K2, V2>();

  @override
  bool containsKey(Object key) => value.containsKey(key);

  @override
  bool containsValue(Object value) => _value.containsValue(value);

  @override
  Iterable<MapEntry<K, V>> get entries => value.entries;

  @override
  void forEach(void Function(K, V) f) {
    value.forEach(f);
  }

  @override
  bool get isEmpty => value.isEmpty;

  @override
  bool get isNotEmpty => value.isNotEmpty;

  @override
  Iterable<K> get keys => value.keys;

  @override
  int get length => value.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K, V) transform) =>
      value.map(transform);

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    final val = _value.putIfAbsent(key, ifAbsent);
    refresh();
    return val;
  }

  @override
  V remove(Object key) {
    final val = _value.remove(key);
    refresh();
    return val;
  }

  @override
  void removeWhere(bool Function(K, V) test) {
    _value.removeWhere(test);
    refresh();
  }

  @override
  Iterable<V> get values => value.values;

  @override
  V update(K key, V Function(V) update, {V Function() ifAbsent}) {
    final val = _value.update(key, update, ifAbsent: ifAbsent);
    refresh();
    return val;
  }

  @override
  void updateAll(V Function(K, V) update) {
    _value.updateAll(update);
    refresh();
  }
}

extension MapExtension<K, V> on Map<K, V> {
  RxMap<K, V> get reactive {
    if (this != null) {
      return RxMap<K, V>(<K, V>{})..addAll(this);
    } else {
      return RxMap<K, V>(null);
    }
  }
}
