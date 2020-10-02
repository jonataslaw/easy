import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../hashset_notifier.dart';
import '../value.dart';

class RxList<E> extends HashSetNotifier
    implements List<E>, ValueListenable<List<E>> {
  RxList([List<E> initial]) {
    if (initial != null) _list = initial;
  }

  StreamController<List<E>> subject;

  HashMap<Stream<List<E>>, StreamSubscription> _subscriptions;

  List<E> get value {
    notifyChildrens();
    return _list;
  }

  set value(List<E> newValue) {
    if (_list == newValue) return;
    _list = newValue;
    updater();
  }

  List<E> call([List<E> v]) {
    if (v != null) {
      this.value = v;
    }
    return this.value;
  }

  void update(void fn(Iterable<E> value)) {
    fn(value);
    refresh();
  }

  void refresh() {
    updater();
    if (subject != null) {
      subject.add(_list);
    }
  }

  Stream<List<E>> get stream {
    subject ??= StreamController<List<E>>.broadcast();
    return subject.stream;
  }

  StreamSubscription<List<E>> listen(
    void Function(List<E>) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) =>
      stream.listen(onData, onError: onError, onDone: onDone);

  /// Binds an existing [Stream<List>] to this [RxList].
  /// You can bind multiple sources to update the value.
  /// Closing the subscription will happen automatically when the observer
  /// Widget ([GetX] or [Obx]) gets unmounted from the Widget tree.
  void bindStream(Stream<List<E>> stream) {
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

  List<E> _list = <E>[];

  @override
  String toString() => value.toString();

  @override
  Iterator<E> get iterator => value.iterator;

  @override
  bool get isEmpty => value.isEmpty;

  // bool get canUpdate {
  //   return _subscriptions.length > 0;
  // }

  @override
  bool get isNotEmpty => value.isNotEmpty;

  // @override

  // final _subscriptions = HashMap<Stream<List<E>>, StreamSubscription>();

  void operator []=(int index, E val) {
    _list[index] = val;
    refresh();
  }

  /// Special override to push() element(s) in a reactive way
  /// inside the List,
  RxList<E> operator +(Iterable<E> val) {
    addAll(val);
    refresh();
    return this;
  }

  E operator [](int index) {
    return value[index];
  }

  void add(E item) {
    _list.add(item);
    refresh();
  }

  @override
  void addAll(Iterable<E> item) {
    _list.addAll(item);
    refresh();
  }

  /// Add [item] to [List<E>] only if [item] is not null.
  void addNonNull(E item) {
    if (item != null) add(item);
  }

  /// Add [Iterable<E>] to [List<E>] only if [Iterable<E>] is not null.
  void addAllNonNull(Iterable<E> item) {
    if (item != null) addAll(item);
  }

  /// Add [item] to [List<E>] only if [condition] is true.
  void addIf(dynamic condition, E item) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) add(item);
  }

  /// Adds [Iterable<E>] to [List<E>] only if [condition] is true.
  void addAllIf(dynamic condition, Iterable<E> items) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) addAll(items);
  }

  @override
  void insert(int index, E item) {
    _list.insert(index, item);
    refresh();
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    _list.insertAll(index, iterable);
    refresh();
  }

  @override
  int get length => value.length;

  /// Removes an item from the list.
  ///
  /// This is O(N) in the number of items in the list.
  ///
  /// Returns whether the item was present in the list.
  @override
  bool remove(Object item) {
    final hasRemoved = _list.remove(item);
    if (hasRemoved) {
      refresh();
    }
    return hasRemoved;
  }

  @override
  E removeAt(int index) {
    final item = _list.removeAt(index);
    refresh();
    return item;
  }

  @override
  E removeLast() {
    final item = _list.removeLast();
    refresh();
    return item;
  }

  @override
  void removeRange(int start, int end) {
    _list.removeRange(start, end);
    refresh();
  }

  @override
  void removeWhere(bool Function(E) test) {
    _list.removeWhere(test);
    refresh();
  }

  @override
  void clear() {
    _list.clear();
    refresh();
  }

  @override
  void sort([int compare(E a, E b)]) {
    _list.sort(compare);
    refresh();
  }

  /// Replaces all existing items of this list with [item]
  void assign(E item) {
    clear();
    add(item);
  }

  /// Replaces all existing items of this list with [items]
  void assignAll(Iterable<E> items) {
    clear();
    addAll(items);
  }

  String get string => value.toString();

  @override
  E get first => value.first;

  @override
  E get last => value.last;

  @override
  bool any(bool Function(E) test) {
    return value.any(test);
  }

  @override
  Map<int, E> asMap() {
    return value.asMap();
  }

  @override
  List<R> cast<R>() {
    return value.cast<R>();
  }

  @override
  bool contains(Object element) {
    return value.contains(element);
  }

  @override
  E elementAt(int index) {
    return value.elementAt(index);
  }

  @override
  bool every(bool Function(E) test) {
    return value.every(test);
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E) f) {
    return value.expand(f);
  }

  @override
  void fillRange(int start, int end, [E fillValue]) {
    _list.fillRange(start, end, fillValue);
    refresh();
  }

  @override
  E firstWhere(bool Function(E) test, {E Function() orElse}) {
    return value.firstWhere(test, orElse: orElse);
  }

  @override
  T fold<T>(T initialValue, T Function(T, E) combine) {
    return value.fold(initialValue, combine);
  }

  @override
  Iterable<E> followedBy(Iterable<E> other) {
    return value.followedBy(other);
  }

  @override
  void forEach(void Function(E) f) {
    value.forEach(f);
  }

  @override
  Iterable<E> getRange(int start, int end) {
    return value.getRange(start, end);
  }

  @override
  int indexOf(E element, [int start = 0]) {
    return value.indexOf(element, start);
  }

  @override
  int indexWhere(bool Function(E) test, [int start = 0]) {
    return value.indexWhere(test, start);
  }

  @override
  String join([String separator = ""]) {
    return value.join(separator);
  }

  @override
  int lastIndexOf(E element, [int start]) {
    return value.lastIndexOf(element, start);
  }

  @override
  int lastIndexWhere(bool Function(E) test, [int start]) {
    return value.lastIndexWhere(test, start);
  }

  @override
  E lastWhere(bool Function(E) test, {E Function() orElse}) {
    return value.lastWhere(test, orElse: orElse);
  }

  @override
  set length(int newLength) {
    _list.length = newLength;
    refresh();
  }

  @override
  Iterable<T> map<T>(T Function(E) f) {
    return value.map(f);
  }

  @override
  E reduce(E Function(E, E) combine) {
    return value.reduce(combine);
  }

  @override
  void replaceRange(int start, int end, Iterable<E> replacement) {
    _list.replaceRange(start, end, replacement);
    refresh();
  }

  @override
  void retainWhere(bool Function(E) test) {
    _list.retainWhere(test);
    refresh();
  }

  @override
  Iterable<E> get reversed => value.reversed;

  @override
  void setAll(int index, Iterable<E> iterable) {
    _list.setAll(index, iterable);
    refresh();
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    _list.setRange(start, end, iterable, skipCount);
    refresh();
  }

  @override
  void shuffle([Random random]) {
    _list.shuffle(random);
    refresh();
  }

  @override
  E get single => value.single;

  @override
  E singleWhere(bool Function(E) test, {E Function() orElse}) {
    return value.singleWhere(test, orElse: orElse);
  }

  @override
  Iterable<E> skip(int count) {
    return value.skip(count);
  }

  @override
  Iterable<E> skipWhile(bool Function(E) test) {
    return value.skipWhile(test);
  }

  @override
  List<E> sublist(int start, [int end]) {
    return value.sublist(start, end);
  }

  @override
  Iterable<E> take(int count) {
    return value.take(count);
  }

  @override
  Iterable<E> takeWhile(bool Function(E) test) {
    return value.takeWhile(test);
  }

  @override
  List<E> toList({bool growable = true}) {
    return value.toList(growable: growable);
  }

  @override
  Set<E> toSet() {
    return value.toSet();
  }

  @override
  Iterable<E> where(bool Function(E) test) {
    return value.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return value.whereType<T>();
  }

  @override
  set first(E value) {
    _list.first = value;
    refresh();
  }

  @override
  set last(E value) {
    _list.last = value;
    refresh();
  }
}

extension ListExtension<E> on List<E> {
  RxList<E> get reactive {
    if (this != null) {
      return RxList<E>(<E>[])..addAllNonNull(this);
    } else {
      return RxList<E>(null);
    }
  }
}
