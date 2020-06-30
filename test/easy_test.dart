import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:easy/src/value.dart';

void main() {
  /// increment this to test of stress
  int times = 1000;
  int last = times - 1;

  Value easyValue = Value(0);
  ValueNotifier value = ValueNotifier(0);

  value.addListener(() {
    if (last == value.value) {
      print("last item of value");
    }
  });
  easyValue.addListener(() {
    if (last == easyValue.value) {
      print("last item of easyValue");
    }
  });

  test('ValueNotifier test', () {
    Stopwatch timer = Stopwatch();
    timer.start();
    for (int i = 0; i < times; i++) {
      value.value = i;
    }
    timer.stop();
    print(value.value.toString() +
        " item value objs time: " +
        timer.elapsedMicroseconds.toString() +
        "ms");
  });

  test('Value test', () {
    Stopwatch timer2 = new Stopwatch();
    timer2.start();
    for (int i = 0; i < times; i++) {
      easyValue.value = i;
    }
    timer2.stop();
    print(easyValue.value.toString() +
        " item easyValue objs time: " +
        timer2.elapsedMicroseconds.toString() +
        "ms");
  });

  print('test ended');
}
