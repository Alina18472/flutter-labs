import 'package:flutter/material.dart';
import 'database.dart';
import 'models/note.dart';
import 'package:intl/intl.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 91, 37, 186)),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});



  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int count=1;
  late DatabaseHelper _db;
  List<Note> _notes =[];
  String _sortBy = 'default';
 

  @override
  void initState() {
    super.initState();
    _db = DatabaseHelper();
    loadNotes();
  }

  void loadNotes() async{
    List<Note> notes = await _db.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  
  void addNote(Note note) async{
    await _db.insertNote(note);
    loadNotes();
  }

  void goToNotePage(String title, {Note? note})async{
    final someNote = await Navigator.push(context,MaterialPageRoute(builder: (context)=>NotePage(title: title, note:note)));
    if(someNote !=null && someNote is Note){
      if(note == null){
        addNote(someNote);
      }
      else{
        await _db.updateNote(someNote);
        loadNotes();
      }
    }
  }
   void confirmDelete(Note note) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text ("Удаление заметки"),
          content:  Text("Вы точно хотите удалить заметку?"),
          actions: [
            TextButton(onPressed: ()=>Navigator.pop(context, false), child: Text("Отменить")),
            TextButton(onPressed: ()=>Navigator.pop(context, true), child: Text("Удалить")),
          ],
        );
      }
    );
    if (confirmed == true){
      await _db.deleteNote(note.id!);
      loadNotes();
    }
   }
  Color getColor(String priority){
    switch(priority){
      case 'Высокий':
        return Colors.red;
      case 'Средний':
        return Colors.orange;
      case 'Низкий':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  void _sortNotes() {
    if (_sortBy == 'priority') {
       _notes.sort((a, b) => _getPriorityValue(a.priority).compareTo(_getPriorityValue(b.priority)));
      
    }
    else if (_sortBy == 'deadline') {
      _notes.sort((a, b) {
        if (a.deadline == null && b.deadline == null) return 0;// Считаем их равными, порядок неважен
        if (a.deadline == null) return 1;//Заметка a должна идти после b (возвращаем 1)
        if (b.deadline == null) return -1;//Заметка a должна идти перед b (возвращаем -1)
        return a.deadline!.compareTo(b.deadline!);
      });
    }
    else if (_sortBy == 'default') {
    _notes.sort((a, b) => a.date.compareTo(b.date)); // Новейшие сначала
  }
  }

  int _getPriorityValue(String priority) {
    switch (priority) {
      case 'Высокий':
        return 0;
      case 'Средний':
        return 1;
      case 'Низкий':
        return 2;
      default:
        return 3;
    }
  }
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        title:Text("Заметки"),
       
        backgroundColor: Color.fromARGB(255, 172, 110, 219),
        actions: [
          DropdownButton<String>(
            value: _sortBy,
            onChanged: (String? newValue) {
              setState(() {
                _sortBy = newValue!;
                _sortNotes();
              });
            },
            items: <String>['default', 'priority', 'deadline']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value == 'priority' ? 'По приоритету' : 
                value == 'deadline'?'По дедлайну':'По умолчанию'),
              );
            }).toList(),
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder:(BuildContext context,int index){
          final note =_notes[index];
          return Card(
            color: Colors.white,
            elevation: 2,
            child:ListTile(
              leading: Icon(Icons.task, color: getColor(note.priority)),
              title:Text(note.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text(note.description),
                  if(note.deadline!= null)
                    Text('Дедлайн: ${DateFormat('dd-MM-yyyy').format(note.deadline!)}',
                    style: TextStyle(color:  Color.fromARGB(255, 142, 87, 185)),)
                ]
              ),
              trailing: IconButton(
                onPressed: ()=> confirmDelete(note),
                icon: Icon(Icons.delete, color:  Color.fromARGB(255, 172, 110, 219)),
              ),
              onTap:()=>goToNotePage("Редактировать заметку", note:note),

            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: ()=>goToNotePage("Создать заметку"),
      tooltip: 'Добавить заметку',
      child:Icon(Icons.add),
    ),
    );
  }

 
}
class NotePage extends StatefulWidget{
  final String title;
  final Note? note;
  const NotePage(
    {super.key,required this.title, required this.note}
  );
  @override
  State<NotePage> createState() => NotePageState();
}
class NotePageState extends State<NotePage>{
  static final _priorities =['Высокий','Средний', 'Низкий'];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _priority='Низкий';
  DateTime? _deadline;
  
  @override
  void initState() {
    
    super.initState();
    if(widget.note !=null){
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
      _priority = widget.note!.priority;
      _deadline = widget.note!.deadline;
    }
  }

  void _saveNote(){
    if(_titleController.text.isEmpty || _descriptionController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Заполните все поля!"))
      );
      return;
    }
    final note = Note(
      id: widget.note?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      priority: _priority,
      date: widget.note?.date??DateTime.now(),
      deadline: _deadline,

    );
    Navigator.pop(context,note);
  }

  void cancel(){
    Navigator.pop(context);
  }

  Future <void> selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked!=null){
      setState(() {
        _deadline =picked;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text(widget.title),
        backgroundColor: const Color.fromARGB(255, 172, 110, 219),
        leading: IconButton(
          onPressed: cancel,
          icon: Icon(Icons. arrow_back)
        ),
      ),
      body:Padding(
        padding: EdgeInsets.only(top:15, left:15,right:15),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Приоритет:"),
              DropdownButton<String>(
                value: _priority,
                onChanged: (String? newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
                items: _priorities.map((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
           
            Padding(
              padding: EdgeInsets.only(top:15, bottom:15),
              child:TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Заголовок',
                  hintText: 'Введите заголовок заметки',
                  border:OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                  )
                ),
              )
            ),
            Padding(
              padding: EdgeInsets.only(top:15, bottom:15),
              child:TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Описание',
                  hintText: 'Введите описание заметки',
                  border:OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                  )
                ),
              )
            ),
            Padding(
              padding: EdgeInsets.only(top:15, bottom:15),
              child: TextButton(onPressed: selectDeadline, child: Text(_deadline==null?"Установить дедлайн":"Дедлайн: ${DateFormat('dd-MM-yyyy').format(_deadline!)}")),
             
            ),
            Padding(

              padding: EdgeInsets.only(top:15,bottom:15),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  ElevatedButton(
                    onPressed: _saveNote,
                    child: Text("Сохранить")
                  ),
                  Container(width: 5),
                  ElevatedButton(
                    onPressed: cancel,
                    child: Text("Отменить")
                  ),
                ]
              ),
            )
          ]
        ),
      ),

    );
    
  }
}