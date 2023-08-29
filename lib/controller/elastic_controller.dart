// ignore_for_file: deprecated_member_use, prefer_const_declarations

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';

class ElasticsearchController {
  final String baseUrl; // Your Laravel API base URL

  ElasticsearchController(this.baseUrl);

  Future<String> uploadAndIndex(File pdfFile, String title) async {
    final url = 'http://192.168.52.1:8000/index';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['title'] = title;

    var stream = http.ByteStream(DelegatingStream.typed(pdfFile.openRead()));
    var length = await pdfFile.length();
    var multipartFile = http.MultipartFile('pdf', stream, length,
        filename: basename(pdfFile.path));

    request.files.add(multipartFile);

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    return responseBody;
  }
}
