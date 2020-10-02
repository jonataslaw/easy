import 'dart:math';

import 'package:flutter/material.dart';
import 'package:easy/easy.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'easy example',
      home: HomePage(),
    );
  }
}

class Counter {
  final int value;
  Counter(this.value);
}

class Foo extends GetState<Counter> {
  Foo() : super(Counter(0));

  void increment() {
    update(Counter(state.value + 1));
  }
}

class HomePage extends StatelessWidget {
  final Foo state = Foo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Store(
                state: () => state,
                builder: (_) {
                  print("count1 rebuild");
                  return Text('${_.value}');
                }),
            RaisedButton(
              onPressed: () {
                state.increment();
              },
              child: Text('Increment two'),
            )
          ],
        ),
      ),
    );
  }
}

class UserStore extends EasyStore {
  final user = User().reactive;
  final counter = 0.reactive;
  final counter2 = 0.reactive;

  final list = [0, 4].reactive;

  void updateUser(String name, int age) {
    user.update((user) {
      user.name = name;
      user.age = age;
    });
  }

  void listInc() => list.add(Random().nextInt(90));
}

class User {
  User({this.name = '', this.age = 18});
  String name;
  int age;
}
