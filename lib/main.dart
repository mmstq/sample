import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sample/todo_model.dart';
import 'package:sample/viewmodel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  DateTime dateToday = DateTime.now();
  DateTime pickedDate = DateTime.now();
  
  final inputDecoration = InputDecoration(
      enabledBorder: OutlineInputBorder(), focusedBorder: OutlineInputBorder());

  final bloc = TodoViewModel();
  
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // editing variables
  bool isEditing = false;
  int editingTodoIndex = -1;

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: StreamBuilder<List<Todo>>(
        stream: bloc.stream,
        initialData: [],
        builder: (ctx, snapshot) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 30, 8, 8),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text('Deadline:')),
                  Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        child: Text("${pickedDate.toLocal()}".split(' ')[0]),
                        onPressed: () => _selectDate(context),
                      ))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text('Task:')),
                  Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: inputDecoration,
                        controller: titleController,
                      ))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text('Description:')),
                  Expanded(
                      flex: 2,
                      child: TextField(
                        maxLines: 2,
                        decoration: inputDecoration,
                        controller: descriptionController,
                      ))
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              width: size.width,
              child: ElevatedButton(
                  child: Text(isEditing?'Modify':'Add/Save'),
                  onPressed: () {
                    final todo = new Todo(
                        date: pickedDate,
                        title: titleController.text,
                        description: descriptionController.text);

                    // resetting the date picker text after saving/modifying todo
                    pickedDate = DateTime.now();

                    if(isEditing){
                      // this runs when we edit todo
                      bloc.modify(editingTodoIndex, todo);
                      isEditing = false;
                      _showSnackBar(context, editingTodoIndex, 'modified');
                    }else {
                      //this runs when we save new todo
                      bloc.add(todo);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('New Todo added'),
                        duration: Duration(milliseconds: 700),
                      ));

                    }
                    // clearing the text in desc and title field
                    descriptionController.clear();
                    titleController.clear();
                  }),
            ),
            Container(
              width: size.width,
              height: 1,
              color: Colors.grey,
            ),
            Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  'TODOs',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.grey.shade700),
                )),
            Expanded(
              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    final DateTime date = snapshot.data[index].date;
                    final isCompleted = snapshot.data[index].isCompleted;
                    final color =
                        isCompleted ? Colors.green : Colors.grey.shade600;
                    final isDue =
                        snapshot.data[index].date.isBefore(DateTime.now());

                    if (snapshot.hasData)
                      return Slidable(
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                titleController.text = snapshot.data[index].title;
                                descriptionController.text = snapshot.data[index].description;
                                pickedDate = snapshot.data[index].date;
                                isEditing = true;
                                editingTodoIndex = index;
                              });
                            },
                            child: Container(
                                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                color: Colors.blueGrey.shade50,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        snapshot.data[index].title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${date.day}-${date.month}-${date.year}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: isDue
                                                ? Colors.red
                                                : Colors.grey.shade800),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        splashRadius: 0,
                                        onPressed: () {
                                          bloc.doComplete(index, isCompleted);
                                          _showSnackBar(context, index,
                                              isCompleted ? 'Incomplete' : 'Done');
                                        },
                                        color: color,
                                        icon: isCompleted
                                            ? Icon(Icons.check_circle_rounded)
                                            : Icon(Icons
                                                .check_circle_outline_rounded),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          actionPane: SlidableBehindActionPane(),
                          actions: getAction(context, isCompleted, index),
                          secondaryActions: getAction(context, isCompleted, index));
                    return Container();
                  }),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> getAction(BuildContext context, bool isCompleted, int index)=><Widget>[
    IconSlideAction(
      caption: isCompleted?'Undo':'Done',
      color: isCompleted?Colors.red:Colors.green,
      icon: isCompleted?Icons.close:Icons.check,
      onTap: () {
        bloc.doComplete(index, isCompleted);
        _showSnackBar(context, index,
            isCompleted ? 'Incomplete' : 'Done');
      },
    ),
  ];

  void _showSnackBar(BuildContext context, int index, String operation) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(milliseconds: 700),
        content: Text('Task ${index+1} is $operation')));
  }

  _selectDate(BuildContext context) async {
    pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Refer step 1
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
      currentDate: pickedDate
    );
    if (pickedDate != null && pickedDate != dateToday)
      setState(() {
        dateToday = pickedDate;
      });
  }
}
