import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:korek_task/screens/test/person.dart';

//192.168.43.197
class ApiClient {
  static const String baseUrl =
      'https://korek.website'; // Replace with your Laravel API URL

  static Future<List<Person>> fetchPeople() async {
    var response = await http.get(Uri.parse('$baseUrl/people'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body)['data'];
      return jsonList.map((json) => Person.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch people');
    }
  }
}
