import 'dart:async';

import 'package:sample/todo_model.dart';

class TodoViewModel {
  final List<Todo> todo = [];
  final counterController = StreamController<List<Todo>>();
  Stream<List<Todo>> get stream => counterController.stream;
  StreamSink<List<Todo>> get sink => counterController.sink;


  void dispose() {
    counterController.close();
  }

  void add(Todo todo){
    this.todo.add(todo);
    this.todo.sort((a,b)=> a.date.compareTo(b.date));
    sink.add(this.todo);
  }

  void modify(int index, Todo todo){
    this.todo[index] = todo;
    this.todo.sort((a,b)=> a.date.compareTo(b.date));
    sink.add(this.todo);

  }

  void doComplete(int index, bool b){
    this.todo[index].isCompleted = !b;
    sink.add(this.todo);
  }
}