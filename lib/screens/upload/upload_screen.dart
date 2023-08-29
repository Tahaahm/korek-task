// ignore_for_file: avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String _filePath = '';
  bool isLoading = false;
  TextEditingController titleController = TextEditingController();
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

  Future<void> uploadToLaravel(String title) async {
    if (_filePath.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(
        'http://192.168.43.197:8000/index'); // Replace with your Laravel API URL

    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('pdf', _filePath));
    request.fields['title'] = title; // Set the title

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        if (title.isNotEmpty) {
          var responseBody = await response.stream.bytesToString();
          var responseJson = json.decode(responseBody);
          var documentId = responseJson['document_id'];
          print('PDF uploaded and indexed successfully');
          showSnackBar(context);
          print('Document ID: $documentId');
        } else {
          print("Title empty");
        }
      } else {
        print('Failed to upload and index PDF');
      }
    } catch (e) {
      print('Error uploading PDF: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Upload File",
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
              children: [
                _filePath.isNotEmpty
                    ? Container(
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
                            hintText: "Enter Title ",
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
                                      "Upload File Here",
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
                                          "Upload File",
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
                    ? GestureDetector(
                        onTap: () {
                          uploadToLaravel(titleController.text);
                        },
                        child: Container(
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
                                    "Upload To Server",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                        ),
                      )
                    : Container(),
                SizedBox(height: 20),
                _filePath.isNotEmpty
                    ? GestureDetector(
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
                              "Cancel",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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

  void showSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('PDF uploaded and indexed successfully'),
      duration: Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Perform an action when the "Undo" button is pressed.
          // For example, you could revert a user's action.
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
