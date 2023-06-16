import 'package:flutter/material.dart';

class FingerprintPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fingerprint Page'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Show Dialog'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Save Fingerprint'),
                  content: Text('Do you want to save the fingerprint?'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Save'),
                      onPressed: () {
                        saveFingerprint();
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void saveFingerprint() {
    // Add your code here to save the fingerprint
    print('Fingerprint saved!');
  }
}
