import 'reactive_list.dart';
import 'iterable_interface.dart';

extension MapExtension<K, V> on Map<K, V> {
  ReactiveMap<K, V> get reactive {
    if (this != null)
      return ReactiveMap<K, V>({})..addAll(this);
    else
      return ReactiveMap<K, V>(null);
  }
}

abstract class BaseReactiveMap<K, V>
    extends IterableInterface<Map<K, V>, MapChanged<K, V>> {
  BaseReactiveMap<KOut, VOut> map<KOut, VOut>(
          MapEntry<KOut, VOut> func(K key, V value)) =>
      MappedReactiveMap(this, func);
}

class ReactiveMap<K, V> extends BaseReactiveMap<K, V> {
  ReactiveMap(Map<K, V> value) : _value = Map.of(value);

  Map<K, V> _value;

  @override
  Map<K, V> get value => Map<K, V>.unmodifiable(_value);

  set value(Map<K, V> other) {
    final change = MapChanged(_value, other);
    _value = Map.of(other);
    notify(change);
  }

  void update(MapChanged<K, V> func(Map<K, V> val)) {
    notify(func(_value));
  }

  void operator []=(K key, V value) {
    final removed = {if (_value.containsKey(key)) key: _value[key]};
    _value[key] = value;
    notify(MapChanged<K, V>(removed, {key: value}));
  }

  void addAll(Map<K, V> items) {
    final removed = <K, V>{
      for (var key in items.keys)
        if (_value.containsKey(key)) key: _value[key]
    };
    _value.addAll(items);
    notify(MapChanged<K, V>(removed, items));
  }

  void clear() {
    final removed = Map<K, V>.unmodifiable(_value);
    _value.clear();
    notify(MapChanged<K, V>(removed, {}));
  }
}

class MappedReactiveMap<K, V, KIn, VIn> extends BaseReactiveMap<K, V> {
  MappedReactiveMap(this.parent, this.func) : _value = parent.value.map(func) {
    parent.addIterableListener(_onChange);
  }

  final BaseReactiveMap<KIn, VIn> parent;
  final MapEntry<K, V> Function(KIn key, VIn value) func;
  final Map<K, V> _value;

  @override
  Map<K, V> get value => Map.unmodifiable(_value);

  @override
  void dispose() {
    parent.removeIterableListener(_onChange);
    super.dispose();
  }

  void _onChange(MapChanged<KIn, VIn> change) {
    final removed = change.removed.map(func);
    final added = change.added.map(func);
    for (var key in removed.keys) {
      _value.remove(key);
    }
    _value.addAll(added);
    notify(MapChanged<K, V>(removed, added));
  }
}

class ListToReactiveMap<K, V, T> extends BaseReactiveMap<K, V> {
  ListToReactiveMap(this.parent, this.func) {
    _value.addEntries(_mapping..addAll(parent.value.map(func)));
    parent.addIterableListener(_onChange);
  }

  final IterableInterface<List<T>, ListChanged<T>> parent;
  final MapEntry<K, V> Function(T item) func;
  final _value = <K, V>{};
  final _mapping = <MapEntry<K, V>>[];

  @override
  Map<K, V> get value => Map.unmodifiable(_value);

  @override
  void dispose() {
    parent.removeIterableListener(_onChange);
    super.dispose();
  }

  void _onChange(ListChanged<T> change) {
    final removed = Map.fromEntries(
        _mapping.sublist(change.start, change.start + change.removed.length));
    final addedMapped = change.added.map(func);
    _mapping.replaceRange(
        change.start, change.start + change.removed.length, addedMapped);
    final added = Map.fromEntries(addedMapped);
    for (var key in removed.keys) {
      _value.remove(key);
    }
    _value.addAll(added);
    notify(MapChanged<K, V>(removed, added));
  }
}

class MapChanged<K, V> {
  MapChanged(Map<K, V> removed, Map<K, V> added)
      : removed = Map.unmodifiable(removed),
        added = Map.unmodifiable(added);

  final Map<K, V> removed;

  final Map<K, V> added;
}
