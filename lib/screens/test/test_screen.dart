// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:korek_task/model/person_model.dart';

class PeopleListScreen extends StatefulWidget {
  @override
  _PeopleListScreenState createState() => _PeopleListScreenState();
}

class _PeopleListScreenState extends State<PeopleListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('People List'),
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (content, index) {
                      return ListTile(
                        title: Text(items[index].name),
                        subtitle: Text(items[index].categories),
                      );
                    }),
              )
            ],
          ),
        ));
  }
}
