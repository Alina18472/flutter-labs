class Note{
  int? id;
  String title;
  String description;
  String priority;
  DateTime date;
  DateTime? deadline;
  

  Note(
    {this.id, required this.title, required this.description,
    required this.date, this.deadline, required this.priority }
  );

  Map<String, dynamic> toMap(){
    return{
      'id':id,
      'title':title,
      'description':description,
      'priority': priority,
      'date':date.toIso8601String(), //конвертирует дату в строку формата 2023-10-2025
      'deadline': deadline?.toIso8601String(),//конвертирует дату в строку формата 2023-10-2025
      
    };
  }
  factory Note.fromMap(Map<String, dynamic> map){
    return Note(
      id:map['id'],
      title:map['title'],
      description: map['description'],
      priority: map['priority'],
      date: DateTime.parse(map['date']),
      deadline: map['deadline']!= null? DateTime.parse(map['deadline']) : null,

    );
  }
}