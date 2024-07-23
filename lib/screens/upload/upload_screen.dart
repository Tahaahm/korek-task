import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String _filePath = '';
  bool isLoading = false;
  TextEditingController titleController = TextEditingController();
  String pdfContent = '';
  bool isArabic = false;
  bool _hasPermission = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['pdf'],
        type: FileType.custom,
      );

      if (result != null) {
        setState(() {
          _filePath = result.files.single.path!;
        });
      }
    } on PlatformException catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<void> uploadToLaravel(String title, String pdfContent) async {
    if (_filePath.isEmpty) {
      Fluttertoast.showToast(
        msg: isArabic ? "الرجاء اختيار ملف PDF" : "Please select a PDF file",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    if (title.isEmpty) {
      Fluttertoast.showToast(
        msg: isArabic ? "الرجاء إدخال عنوان" : "Please enter a title",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    print(
        'Extracted PDF Content: $pdfContent'); // Print extracted content for debugging

    var url = Uri.parse('https://korek.website/index');

    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('pdf', _filePath));
    request.fields['title'] = title;
    request.fields['pdf_content'] = pdfContent;

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');
      if (response.statusCode == 200) {
        var responseJson = json.decode(responseBody);
        var documentId = responseJson['document_id'];
        var pdfUrl = responseJson['pdf_url'];
        print('PDF uploaded and indexed successfully');
        showSnackBar(context, pdfUrl);
        print('Document ID: $documentId');
        setState(() {
          _filePath = '';
          titleController.clear();
        });
      } else {
        print('Failed to upload and index PDF');
        print('Error response: $responseBody');
      }
    } catch (e) {
      print('Error uploading PDF: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> readPdfContent() async {
    final fileName = _filePath.split('/').last;
    final pdfId =
        fileName.split('_').first; // Assuming file names are like '001_*.pdf'

    try {
      final file = File(_filePath);
      final bytes = await file.readAsBytes();
      final pdfDocument = PdfDocument(inputBytes: bytes);

      final textExtractor = PdfTextExtractor(pdfDocument);
      final text = StringBuffer();
      for (int i = 0; i < pdfDocument.pages.count; i++) {
        String pageText = textExtractor.extractText(startPageIndex: i);
        text.write(pageText);
      }

      pdfDocument.dispose();
      return preprocessText(text.toString());
    } catch (e) {
      print('Error reading PDF: $e');
      return 'Failed to read PDF content.';
    }
  }

  String preprocessText(String text) {
    // Replace common misrecognized characters or encoding issues
    if (isArabic) {
      text = text.replaceAll('غ', 'م'); // Example replacement for Arabic
    }
    // Add more replacements as needed for both Arabic and English
    return text;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? "رفع ملف" : "Upload File",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
          ).copyWith(top: 25),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _filePath.isNotEmpty
                    ? Center(
                        child: Container(
                          height: 50,
                          width: 300,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  color: Colors.grey,
                                  offset: Offset(3, 2),
                                ),
                                BoxShadow(
                                  blurRadius: 4,
                                  color: Colors.grey[300]!,
                                  offset: Offset(-3, 2),
                                )
                              ]),
                          child: TextFormField(
                            controller: titleController,
                            textAlign:
                                isArabic ? TextAlign.right : TextAlign.left,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              border: InputBorder.none,
                              hintText:
                                  isArabic ? "أدخل العنوان" : "Enter Title",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                            ),
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onChanged: (value) {},
                            onFieldSubmitted: (value) {},
                            onTap: () {},
                          ),
                        ),
                      )
                    : Container(),
                _filePath.isNotEmpty
                    ? SizedBox(
                        height: 20,
                      )
                    : Container(),
                _filePath.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/image/pdf-icon.png",
                            height: 80,
                          ),
                          SizedBox(height: 10),
                          Text(_filePath),
                          SizedBox(height: 10),
                        ],
                      )
                    : GestureDetector(
                        onTap: _pickFile,
                        child: Container(
                          height: _filePath.isEmpty ? 600 : 300,
                          width: double.maxFinite,
                          color: Colors.white,
                          child: DottedBorder(
                            dashPattern: [2, 4],
                            borderType: BorderType.RRect,
                            radius: Radius.circular(12),
                            padding: EdgeInsets.all(6),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      "assets/animation/upload.json",
                                      height: 200,
                                    ),
                                    Text(
                                      isArabic
                                          ? "تحميل الملف هنا"
                                          : "Upload File Here",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 45),
                                    Container(
                                      height: 50,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          isArabic ? "رفع ملف" : "Upload File",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),
                _filePath.isNotEmpty
                    ? Center(
                        child: GestureDetector(
                          onTap: () async {
                            String pdfContent = await readPdfContent();
                            uploadToLaravel(titleController.text, pdfContent);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 50,
                            width: 240,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8)),
                            child: isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ))
                                : Center(
                                    child: Text(
                                      isArabic
                                          ? "رفع إلى الخادم"
                                          : "Upload To Server",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(height: 20),
                _filePath.isNotEmpty
                    ? Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _filePath = '';
                            });
                          },
                          child: Container(
                            height: 50,
                            width: 240,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: Text(
                                isArabic ? "إلغاء" : "Cancel",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSnackBar(BuildContext context, String pdfUrl) {
    // Ensure the URL is correctly formatted for accessing the PDF
    final fileName = pdfUrl.split('/').last;
    final newPdfUrl = 'https://korek.website/pdfs/$fileName';

    final snackBar = SnackBar(
      content: Text(isArabic
          ? 'تم تحميل PDF وفهرسته بنجاح. URL: $newPdfUrl'
          : 'PDF uploaded and indexed successfully. URL: $newPdfUrl'),
      duration: Duration(seconds: 3),
      action: SnackBarAction(
        label: isArabic ? 'فتح' : 'Open',
        onPressed: () async {
          if (await canLaunch(newPdfUrl)) {
            await launch(newPdfUrl);
          } else {
            throw 'Could not launch $newPdfUrl';
          }
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _checkPermissionStatus() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {
        setState(() {
          _hasPermission = true;
        });
      } else {
        _requestPermission();
      }
    } else {
      setState(() {
        _hasPermission = true;
      });
    }
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {
        setState(() {
          _hasPermission = true;
        });
      }
    }
  }
}
