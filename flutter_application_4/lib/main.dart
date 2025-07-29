import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
void main() {
  runApp(
     MyApp(),
    
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(),
    );
  }
}

class AppDataProvider extends InheritedWidget {
  final String name;
  final int age;

  const AppDataProvider(
    {super.key,required this.name,required this.age,required super.child});

  static AppDataProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppDataProvider>();
  }

  @override
  bool updateShouldNotify(AppDataProvider oldWidget) {
    return name != oldWidget.name || age != oldWidget.age;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();


 @override
  Widget build(BuildContext context) {
    final info = AppDataProvider.of(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (info != null&& info.name.isNotEmpty)
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Информация о вас:',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Ваше имя: ${info.name}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Ваш возраст: ${info.age}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 35),
                    ],
                  ),
                ],
              ),
            Column(
              children: [
                Text(
                  'Представьтесь:',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 35),
                TextField(
                  controller: _nameController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-Я]')), // Разрешаем только буквы
                  ],
                  decoration: InputDecoration(
                    labelText: 'Ваше имя',
                    hintText: 'Введите ваше имя',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _nameController.clear();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text('Войти'),
                  onPressed: () {
                    String name = _nameController.text;
                    if (name.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SecondPage(name: name),
                        ),
                      );
                    } 
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Введите ваше имя'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class SecondPage extends StatefulWidget {
  final String name;

  const SecondPage(
    {super.key,required this.name});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final TextEditingController _dateController = TextEditingController();
  DateTime? _date;



  Future<void> _getDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.name}, добро пожаловать!',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                'Укажите вашу дату рождения',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 35),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _getDate(context),
                decoration: InputDecoration(
                  hintText: 'Дата рождения',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _dateController.clear();
                        _date = null;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_date != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThirdPage(
                          name: widget.name,
                          date: _date!,
                        ),
                      ),
                    );
                  } 
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Выберите дату рождения'),
                      ),
                    );
                  }
                },
                child:Text('Рассчитать возраст'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  final String name;
  final DateTime date;

  const ThirdPage({super.key,required this.name,required this.date});

  int getAge(DateTime date) {
    final today = DateTime.now();
    int age = today.year - date.year;
    if (today.month < date.month || (today.month == date.month && today.day < date.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final int age = getAge(date);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$name, вам $age лет',
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newProvider = AppDataProvider(
                  name: name,
                  age: age,
                  child: const HomePage(),
                );

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => newProvider),
                  (route) => false,
                );
              },
              child: const Text('Вернуться на главную'),
            ),
          ],
        ),
      ),
    );
  }
}