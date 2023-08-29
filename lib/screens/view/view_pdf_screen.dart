// ignore_for_file: unused_local_variable, use_key_in_widget_constructors, prefer_const_constructors, prefer_const_constructors_in_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PdfHtmlViewScreen extends StatelessWidget {
  final String htmlContent; // Store the HTML content
  final String searchContent;

  PdfHtmlViewScreen({required this.htmlContent, required this.searchContent});

  @override
  Widget build(BuildContext context) {
    WebViewController? webViewControler;
    return Scaffold(
      appBar: AppBar(title: Text('PDF HTML View')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WebView(
          initialUrl: Uri.dataFromString(
            applyFontSizeToHtml(htmlContent, searchContent, fontSize: 30),
            mimeType: 'text/html',
            encoding: Encoding.getByName('utf-8'),
          ).toString(),
        ),
      ),
    );
  }

  String applyFontSizeToHtml(String content, String searchText,
      {double fontSize = 16}) {
    final caseInsensitiveSearchText = searchText.toLowerCase();
    final highlightedContent = content.replaceAllMapped(
      RegExp(searchText, caseSensitive: false),
      (match) =>
          '<span style="background-color: red; color: white;">${match.group(0)}</span>',
    );

    final styledHtmlContent = '''
    <html>
    <head>
        <style>
            body {
                font-size: ${fontSize}px;
            }
        </style>
    </head>
    <body>
        $highlightedContent
    </body>
    </html>
  ''';

    return styledHtmlContent;
  }
}
