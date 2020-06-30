import 'reactive_map.dart';
import 'iterable_interface.dart';

extension ListExtension<E> on List<E> {
  ReactiveList<E> get reactive {
    if (this != null)
      return ReactiveList<E>([])..addAll(this);
    else
      return ReactiveList<E>(null);
  }
}

class ReactiveList<T> extends BaseReactiveList<T> {
  ReactiveList(Iterable<T> value) : _value = value.toList();

  List<T> _value;

  @override
  List<T> get value => List<T>.unmodifiable(_value);

  set value(List<T> other) {
    final change = ListChanged(0, _value, other);
    _value = List.of(other);
    notify(change);
  }

  void update(ListChanged<T> func(List<T> val)) {
    notify(func(_value));
  }

  void operator []=(int index, T item) {
    final removed = _value[index];
    _value[index] = item;
    notify(ListChanged<T>(index, [removed], [item]));
  }

  set first(T item) {
    final removed = [if (_value.length > 0) _value.first];
    _value.first = item;
    notify(ListChanged<T>(0, removed, [item]));
  }

  set last(T item) {
    final removed = [if (_value.length > 0) _value.last];
    _value.last = item;
    notify(ListChanged<T>(0, removed, [item]));
  }

  void add(T item) {
    _value.add(item);
    notify(ListChanged<T>(_value.length - 1, [], [item]));
  }

  void addAll(Iterable<T> items) {
    final len = _value.length;
    _value.addAll(items);
    notify(ListChanged<T>(len, [], items));
  }

  void clear() {
    final removed = List<T>.unmodifiable(_value);
    _value.clear();
    notify(ListChanged<T>(0, removed, []));
  }

  void insert(int index, T item) {
    _value.insert(index, item);
    notify(ListChanged<T>(index, [], [item]));
  }

  void insertAll(int index, Iterable<T> items) {
    _value.insertAll(index, items);
    notify(ListChanged<T>(index, [], items));
  }

  void setAll(int index, Iterable<T> items) {
    final removed = _value.sublist(index, index + items.length);
    _value.setAll(index, items);
    notify(ListChanged<T>(index, removed, items));
  }

  bool remove(T item) {
    final index = _value.indexOf(item);
    if (index < 0) {
      return false;
    }
    removeAt(index);
    return true;
  }

  T removeAt(int index) {
    final result = _value.removeAt(index);
    notify(ListChanged<T>(index, [result], []));
    return result;
  }

  T removeLast() {
    final result = _value.removeLast();
    notify(ListChanged<T>(_value.length - 1, [result], []));
    return result;
  }

  void setRange(int start, int end, Iterable<T> items, [int skipCount = 0]) {
    if (end <= start) {
      return;
    }
    final removed = _value.sublist(start, end);
    _value.removeRange(start, end);
    notify(ListChanged<T>(start, removed, items));
  }

  void removeRange(int start, int end) {
    if (end <= start) {
      return;
    }
    final removed = _value.sublist(start, end);
    _value.removeRange(start, end);
    notify(ListChanged<T>(start, removed, []));
  }
}

class MappedReactiveList<T, TIn> extends BaseReactiveList<T> {
  MappedReactiveList(this.parent, this.func)
      : _value = parent.value.map(func).toList() {
    parent.addIterableListener(_onChange);
  }

  final BaseReactiveList<TIn> parent;
  final T Function(TIn value) func;
  final List<T> _value;

  @override
  List<T> get value => List.unmodifiable(_value);

  @override
  void dispose() {
    parent.removeIterableListener(_onChange);
    super.dispose();
  }

  void _onChange(ListChanged<TIn> change) {
    final removed =
        _value.sublist(change.start, change.start + change.removed.length);
    final added = change.added.map<T>(func);
    _value.replaceRange(
        change.start, change.start + change.removed.length, added);
    notify(ListChanged<T>(change.start, removed, added));
  }
}

class ListChanged<T> {
  ListChanged(this.start, Iterable<T> removed, Iterable<T> added)
      : removed = List.unmodifiable(removed),
        added = List.unmodifiable(added);

  final int start;
  final List<T> removed;
  final List<T> added;
}

abstract class BaseReactiveList<T>
    extends IterableInterface<List<T>, ListChanged<T>> {
  BaseReactiveList<TOut> map<TOut>(TOut f(T x)) =>
      MappedReactiveList<TOut, T>(this, f);

  BaseReactiveMap<K, V> toMap<K, V>(MapEntry<K, V> f(T x)) =>
      ListToReactiveMap<K, V, T>(this, f);
}
