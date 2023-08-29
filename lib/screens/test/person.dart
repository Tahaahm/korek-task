class Person {
  final String title;
  final int age;

  Person({required this.title, required this.age});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      title: json['title'],
      age: json['age'],
    );
  }
}
