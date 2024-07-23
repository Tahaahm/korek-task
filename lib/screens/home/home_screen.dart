// ignore_for_file: avoid_print, prefer_const_constructors, sized_box_for_whitespace, use_build_context_synchronously, unused_element, prefer_const_declarations, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> fetchData() async {
    String apiUrl = 'https://korek.website/fetch';

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

  Future<void> deleteDocumentsByTitle(String titleToDelete) async {
    setState(() {
      _isLoading = true;
    });

    final deleteUrl =
        'https://korek.website/delete'; // Your delete API endpoint

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ' + base64Encode(utf8.encode('taha:taha123')),
    };

    final body = json.encode({
      'title': titleToDelete,
    });

    try {
      final request = http.Request('DELETE', Uri.parse(deleteUrl))
        ..headers.addAll(headers)
        ..body = body;

      final response = await request.send();

      if (response.statusCode == 200) {
        print('Document deleted successfully');
        await fetchData();
        Fluttertoast.showToast(
          msg: "Document deleted successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Failed to delete document');
        print('Response: $responseBody');
        Fluttertoast.showToast(
          msg: "Failed to delete document",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> openPdfUrl(String pdfUrl) async {
    final fileName = pdfUrl.split('/').last;
    final newPdfUrl = 'https://korek.website/pdfs/$fileName';

    if (await canLaunch(newPdfUrl)) {
      await launch(newPdfUrl);
    } else {
      Fluttertoast.showToast(
        msg: "Could not launch PDF",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : titlesAndContent.isEmpty
              ? Center(child: Text('No data available'))
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: titlesAndContent.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () {
                          openPdfUrl(titlesAndContent[index]['pdf_url']);
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
                          padding: EdgeInsets.only(
                            left: 5,
                            right: 5,
                            top: 12,
                            bottom: 12,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/image/pdf-icon.png",
                                height: 45,
                                width: 45,
                              ),
                              SizedBox(width: 15),
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
                                    print(titlesAndContent[index]['title']);
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
