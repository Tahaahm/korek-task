// ignore_for_file: avoid_print, prefer_const_constructors, sized_box_for_whitespace, use_build_context_synchronously, unused_element, prefer_const_declarations, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:korek_task/screens/view/view_pdf_screen.dart';
import '../../config/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> titlesAndContent = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

//fetch section
  Future<void> fetchData() async {
    String apiUrl = 'http://192.168.43.197:8000/fetch';

    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          titlesAndContent =
              List<Map<String, dynamic>>.from(data['titlesAndContent'])
                  .reversed
                  .toList();
          _isLoading = false;
        });
      } else {
        print('Error fetching titles and content: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  // delete section
  Future<void> deleteDocumentsByTitle(String titleToDelete) async {
    setState(() {
      _isLoading = true;
    });
    final elasticsearchUrl = 'http://192.168.43.197:9200/book/_search';
    // Replace 'your_elasticsearch_url' and 'your_index_name' with actual values.

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ' + base64Encode(utf8.encode('taha:taha123')),
    };

    final query = {
      'query': {
        'match': {'title': titleToDelete}
      }
    };

    try {
      final response = await http.post(Uri.parse(elasticsearchUrl),
          headers: headers, body: json.encode(query));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        final hits = responseData['hits']['hits'];

        for (var hit in hits) {
          final documentId = hit['_id'];
          final deleteUrl = 'http://192.168.43.197:9200/book/_doc/$documentId';

          final deleteResponse =
              await http.delete(Uri.parse(deleteUrl), headers: headers);

          if (deleteResponse.statusCode == 200) {
            print('Document deleted successfully. ID: $documentId');
            await fetchData();
          } else {
            print('Failed to delete document. ID: $documentId');
          }
        }
      } else {
        print('Failed to search for documents');
        print('Response: ${response.body}');
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.greyColor.withOpacity(0.1),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : titlesAndContent.isEmpty
                ? Center(child: Text('No data available'))
                : FutureBuilder(
                    future: fetchData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Text("Error");
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 15),
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: titlesAndContent.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              borderRadius: BorderRadius.circular(5),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (builder) => PdfHtmlViewScreen(
                                        htmlContent: titlesAndContent[index]
                                            ['content'],
                                        searchContent: ''),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey[300]!,
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                        offset: Offset(2, 2),
                                      ),
                                      BoxShadow(
                                        color: Colors.white70,
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                        offset: Offset(-2, -2),
                                      ),
                                    ]),
                                margin: EdgeInsets.only(bottom: 5, top: 5),
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Row(
                                  children: [
                                    Text(
                                      titlesAndContent[index]['title']!,
                                      style: TextStyle(fontSize: 18),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(child: Container()),
                                    IconButton(
                                        onPressed: () {
                                          deleteDocumentsByTitle(
                                              titlesAndContent[index]['title']);
                                          print(
                                              titlesAndContent[index]['title']);
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.grey,
                                        )),
                                    // IconButton(
                                    //   onPressed: () {
                                    //     Navigator.push(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //         builder: (builder) =>
                                    //             PdfHtmlViewScreen(
                                    //                 htmlContent:
                                    //                     titlesAndContent[index]
                                    //                         ['content'],
                                    //                 searchContent: ''),
                                    //       ),
                                    //     );
                                    //   },
                                    //   icon: Icon(
                                    //     Icons.view_agenda,
                                    //     color: Colors.grey,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ));
  }
}
