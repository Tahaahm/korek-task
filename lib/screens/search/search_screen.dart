// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, must_be_immutable, unrelated_type_equality_checks, avoid_print, prefer_const_constructors_in_immutables, dead_code, unused_local_variable, prefer_interpolation_to_compose_strings, unnecessary_null_comparison, unused_import, deprecated_member_use, use_build_context_synchronously, prefer_const_declarations, unnecessary_brace_in_string_interps, unused_field, unused_element

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:korek_task/config/colors.dart';
import 'package:http/http.dart' as http;
import 'package:korek_task/screens/view/view_pdf_screen.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;

  Future<void> _performSearch(String query) async {
    var username = 'taha';
    var password = 'taha123';
    var basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    String apiUrl =
        'http://192.168.43.197:8000/search?query=$query'; // Replace with your API endpoint

    try {
      setState(() {
        isLoading = true;
      });
      if (query != null) {
        var response = await http.get(
          Uri.parse(apiUrl),
        );

        if (response.statusCode == 200) {
          setState(() {
            searchResults = json.decode(response.body)[
                'results']; // Replace with the actual key in the response JSON
            print(searchResults);
          });
        } else {
          print('Error searching PDF: ${response.statusCode}');
        }
        setState(() {
          isLoading = false;
        });
      } else {
        // Handle the case where query is null
      }
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildWebView(String text) {
    final webViewHtml = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
      $text
    </body>
    </html>
  ''';

    // Generate a random number or string
    // final randomQuery = DateTime.now().millisecondsSinceEpoch.toString();

    return Container(
      decoration: BoxDecoration(color: Colors.white10),
      width: double.infinity,
      height: 150,
      child: WebView(
        backgroundColor: Colors.transparent,
        initialUrl: 'data:text/html;charset=utf-8,' +
            Uri.encodeComponent(
                webViewHtml), // Append the random query parameter
        javascriptMode: JavascriptMode.disabled,
        onWebViewCreated: (controller) {
          controller.clearCache();
          controller.loadUrl(
            Uri.dataFromString(
              webViewHtml,
              mimeType: 'text/html',
              encoding: Encoding.getByName('utf-8'),
            ).toString(),
          );
        },
      ),
    );
  }

  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyColor.withOpacity(0.2),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: [
            Container(
              height: 55,
              margin: EdgeInsets.symmetric(
                horizontal: 8,
              ).copyWith(top: 30),
              decoration: BoxDecoration(
                color: AppColor.backgroudColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.greyColor.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    child: Icon(Icons.search),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search Your File",
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                      onEditingComplete: () {
                        setState(() {});
                      },
                      onChanged: (value) {},
                      onFieldSubmitted: (value) {
                        setState(() {
                          _performSearch(value);
                        });
                      },
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _performSearch(searchController.text);
                });
              },
              child: isLoading ? CircularProgressIndicator() : Text('Search'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final title = searchResults[index]['title'];
                  final pdfContent =
                      searchResults[index]['highlight']['pdf_content'].join("");
                  final content = searchResults[index]['content'];
                  var highlightedTextWidget = buildWebView(pdfContent);

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfHtmlViewScreen(
                            htmlContent: content,
                            searchContent: searchController.text,
                          ), // Pass the HTML content
                        ),
                      );
                      print("object");
                    },
                    child: Card(
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(
                              searchResults[index]['title'],
                            ),
                            Expanded(child: Container()),
                            IconButton(
                              onPressed: () async {
                                String pdfPath =
                                    searchResults[index]['file_path'];
                                String fullPdfUrl =
                                    'http://192.168.43.197:8000/' + pdfPath;
                                print("Full Url:" + fullPdfUrl);
                                print("Full Url:" + fullPdfUrl);
                                await downloadPdf(fullPdfUrl);
                                _openDownloadedPdf();
                              },
                              icon: Icon(Icons.download),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PdfHtmlViewScreen(
                                      htmlContent: content,
                                      searchContent: searchController.text,
                                    ), // Pass the HTML content
                                  ),
                                );
                              },
                              icon: Icon(Icons.view_agenda),
                            ),
                          ],
                        ), // Adjust this to match your response structure
                        subtitle:
                            highlightedTextWidget, // Adjust this to match your response structure
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _openDownloadedPdf() async {
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory?.path}/downloaded_file.pdf';

    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      print("Error opening file");
    }
  }

  Future<void> _checkPermissionStatus() async {
    PermissionStatus status = await Permission.storage.status;
    setState(() {
      _hasPermission = status.isGranted;
      print(_hasPermission);
    });
  }

  Future<void> _requestPermission() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
    }
  }

  Future<void> downloadPdf(String url) async {
    try {
      if (_hasPermission) {
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory?.path}/downloaded_file.pdf';

        Dio dio = Dio();
        await dio.download(url, filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF downloaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission not granted')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download PDF')),
      );
    }
  }
}
