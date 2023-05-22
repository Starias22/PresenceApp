/*import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _dateTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DateTimePickerFormField(
                decoration: InputDecoration(
                  labelText: 'Date and Time',
                  border: OutlineInputBorder(),
                ),
                initialValue: DateTime.now(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a date and time';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _dateTime = value;
                  });
                },
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDate: DateTime.now(),
                inputType: InputType.both,
                format: DateFormat('yyyy-MM-dd HH:mm'),
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Submit the form data
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
