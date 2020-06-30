# easy

The easiest state manager for Flutter.

## Why Easy?

Flutter already has a lot of state managers (a lot of them!), But I think it's incredible how there are still niches and more niches today.
Recently someone questioned in my other lib (Get), if there was a middle ground between using Simple State Management, and reactive State Management, because both are extreme. One updates the screen through a hashset of callbacks, the most simplistic approach that can exist (that's why RAM is so economical), and the second is a highly powerful management, which uses streams under the hood and can solve literally any problem.
Personally, I use GetX with reactive management in my projects, simply because I am demanding when it comes to state management. However, many people just don't like streams, and no matter how much you say they're awesome, you're not going to convince them.
That's when I came up with the idea of ​​using callback HashSets (like the simple state manager) to do something reactive, and the result was this.
Easy does not work with Streams, and does not work with ChangeNotifier.
In fact, it is somewhat similar to ChangeNotifier, but it doesn't use ObservableList or anything like that.
Why hashset? Why not List? Why not ObservableList?
Well, I think the Flutter team has a good reason to base ChangeNotifier on an ObservableList, but we don't have that. Even because the listener with Easy will be created vertically, from the reactive variable to the widget.
It is something that GetX does automatically, but here you don't need a ".value", on the other hand, you need to put your variable inside a callback.
Anyway, this is just another state management solution, quite different from the conventional one, which has a good performance.
You can fully integrate it with GetX, including EasyStore is a DisposableInterface, which responds to the controllers' lifecycle. That's it, let's see now how Easy works:


add ".reactive" to the end of your variable.

```dart
var name = 'Jonny'.reactive;
```

Insert the Widget you want to change within an EasyBuilder.
```dart
EasyBuilder(($) => Text($(name))),
```

There, now whenever name is changed, it will be updated on the screen.

You can change name in several ways.
The first is accessing its value, just like in GetX

```dart
name.value = 'Pietro';
```
or add literally within name:

```dart
name('Pietro');
```

in the same way you can get the value of name with name.value or with name()

Only within GetBuilder are you required to enclose your reactive variable in a "tracker".
In the example we use the symbol "$" as a tracker, you can use literally anything.


What if I want to access the value of a reactive variable, elsewhere? how do I do?

```dart
class UserStore extends EasyStore {
var name = 'Jonny'.reactive;
}

class HomePage extends StatelessWidget {
  final state = Easy.put(UserStore());
  
  @override
  Widget build(BuildContext context) {
  return EasyBuilder(($) => Text($(state.name)));
}  
```
on other screen:
```dart
class Other extends StatelessWidget {
 
  @override
  Widget build(BuildContext context) {
  UserStore state = Easy.find();
  return EasyBuilder(($) => Text($(state.name)));
}  
```
When name is changed, it will be changed automatically on both screens.

Okay, but what if I want to reactivate an entire class, is that possible?
Well, this is much easier here than any other approach in the world. Easy not, ridiculously easy.

create a class

```dart
class User {
  User({this.name = 'Jonny', this.age = 18});
  String name;
  int age;
}


```

Make your class reactive.

```dart
final user = User().reactive;
```

Let's say you need to display a user's name and age, and you want it to change when you change data. How to do this?
This is your widget:
```dart
 EasyBuilder(($) {
              var user = $(state.user);
              return Text('Name: ${user.name} Age: ${user.age}');
            }),
```

To change it you just need to call update, and update the variables you want. Ridiculously easy.

user.update((user) {
      user.name = 'Pietro';
      user.age = 16;
    });

Done!

I believe it was easy, very easy for you.


