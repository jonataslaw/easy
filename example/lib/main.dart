import 'package:flutter/material.dart';
import 'package:easy/easy.dart';

void main() => runApp(App());

class UserStore extends EasyStore {
  final user = User().reactive;
  final counter = 0.reactive;
  final counter2 = 0.reactive;

  void updateUser(String name, int age) {
    user.update((user) {
      user.name = name;
      user.age = age;
    });
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'easy example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key key}) : super(key: key);

  final UserStore state = Easy.put(UserStore());

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
            EasyBuilder((_) {
              print("count1 rebuild");
              return Text('${_(state.counter)}');
            }),
            EasyBuilder(($) => Text('${$(state.counter2)}')),
            EasyBuilder(($) {
              var user = $(state.user);
              return Text('Name: ${user.name} Age: ${user.age}');
            }),
            // BUTTONS
            RaisedButton(
              onPressed: () => state.updateUser('Jonny Borges', 21),
              child: Text('Update name and age'),
            ),
            RaisedButton(
              onPressed: () => state.counter(state.counter() + 1),
              child: Text('Increment one'),
            ),
            RaisedButton(
              onPressed: () => state.counter2.value++,
              child: Text('Increment two'),
            )
          ],
        ),
      ),
    );
  }
}

class User {
  User({this.name = '', this.age = 18});
  String name;
  int age;
}
