import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 54, 15, 121)),
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
  
  double textSize=22;
  int tasks = 8;
  void _incrementTask(){
    setState((){
      tasks++;
    });
  }
  void _goToSecondPage(int index){
    if (index%2==0){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecondPage(),
        ),
      );
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Задачи"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _incrementTask, icon:Icon(Icons.add))
        ],
      ),
      body: ListView.builder(
        padding:EdgeInsets.only(top: 15),
        itemCount: tasks,
        itemBuilder: (BuildContext context, int index){
          if(index % 2!=0){
            return Opacity(
              opacity: 0.5,
              child: ListTile(
              leading: Icon(Icons.task),
              title: Text("Задача: $index"),
              subtitle: Text("Описание: $index"),
              trailing: IconButton(
                onPressed:()=>_goToSecondPage(index),
                icon:Icon(Icons.arrow_forward)),
              titleTextStyle: TextStyle(fontSize: 18, color: Colors.black),
              subtitleTextStyle: TextStyle(fontSize: 16,color: Colors.black),
            ));
            
          }
          else{
            return Opacity(
              opacity:1,
              child:ListTile(
                leading: Icon(Icons.task),
                title:Text("Задача: $index"),
                subtitle: Text("Описание: $index"),
                trailing: IconButton(
                  onPressed:()=>_goToSecondPage(index),
                  icon:Icon(Icons.arrow_forward)),
                titleTextStyle: TextStyle(fontSize:18, color:Colors.black),
                subtitleTextStyle: TextStyle(fontSize:16, color:Colors.black)

              )
            );
          }
        },
        
      ),
      
    );
  }
}
class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Вы на другой странице"),
      ),
      body: Container(
        child: Text("ПРивет")
          
      ),
    );
   
  }
}