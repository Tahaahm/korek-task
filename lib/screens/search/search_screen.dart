import 'dart:convert';
import 'package:korek_task/screens/view/view_pdf_screen.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lottie/lottie.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;
  int cardsToShow = 3;
  bool _searchPerformed = false;

  Future<void> _performSearch(String query) async {
    String apiUrl =
        'https://korek.website/search?query=${Uri.encodeComponent(query)}';

    try {
      setState(() {
        isLoading = true;
        searchResults.clear(); // Clear previous search results
        _searchPerformed = true; // Mark that a search has been performed
      });

      if (query.isNotEmpty) {
        var response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          setState(() {
            searchResults = json.decode(response.body)['results'];
          });

          // Print search results for debugging
          print(searchResults);
        } else {
          print('Error searching PDF: ${response.statusCode}');
        }
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildWebView(String htmlContent) {
    final webViewHtml = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; }
        em { color: red; font-weight: bold; }
      </style>
    </head>
    <body>
      $htmlContent
    </body>
    </html>
  ''';

    return Container(
      decoration: BoxDecoration(color: Colors.white),
      width: double.infinity,
      height: 150,
      child: WebView(
        backgroundColor: Colors.transparent,
        initialUrl:
            'data:text/html;charset=utf-8,' + Uri.encodeComponent(webViewHtml),
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: [
            Container(
              height: 55,
              margin: EdgeInsets.symmetric(horizontal: 8).copyWith(top: 30),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                          border: InputBorder.none,
                          hintText: "Search Your File",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                        onEditingComplete: () {
                          setState(() {});
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                        onFieldSubmitted: (value) {
                          setState(() {
                            _performSearch(value);
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  _performSearch(searchController.text);
                });
              },
              child: Container(
                alignment: Alignment.center,
                width: double.maxFinite,
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _searchPerformed
                  ? (searchResults.isEmpty && !isLoading
                      ? SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  'assets/animation/search_empty.json',
                                  width: 250,
                                  height: 250,
                                  repeat: false,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Result is empty. Please try another search.',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        )
                      : LazyLoadScrollView(
                          onEndOfPage: () {
                            setState(() {
                              cardsToShow +=
                                  3; // Load 3 more cards when reaching the end
                            });
                          },
                          scrollOffset: 100,
                          child: ListView.builder(
                            itemCount: searchResults.length > cardsToShow
                                ? cardsToShow
                                : searchResults.length,
                            itemBuilder: (context, index) {
                              final title = searchResults[index]['title'];
                              final highlight =
                                  searchResults[index]['highlight'];
                              final pdfContent = highlight != null &&
                                      highlight is List &&
                                      highlight.isNotEmpty
                                  ? highlight.join(" ")
                                  : '';
                              final content = searchResults[index]['content'];
                              var highlightedTextWidget =
                                  buildWebView(pdfContent);

                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PdfHtmlViewScreen(
                                            htmlContent: content,
                                            searchContent:
                                                searchController.text,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          bottom: 15, left: 10, right: 10),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                            offset: Offset(2, 2),
                                          ),
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                            offset: Offset(-2, -2),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        title: Row(
                                          children: [
                                            Text(title),
                                            Expanded(child: Container()),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PdfHtmlViewScreen(
                                                      htmlContent: content,
                                                      searchContent:
                                                          searchController.text,
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: Icon(Icons.view_agenda),
                                            ),
                                          ],
                                        ),
                                        subtitle: highlightedTextWidget,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ))
                  : Center(
                      child: Text(
                        'Please perform a search.',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
