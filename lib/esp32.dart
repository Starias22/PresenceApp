
import 'package:http/http.dart' as http;
import 'package:presence_app/utils.dart';
class ESP32{

//final String ipAddress='172.16.65.1';
  final String ipAddress='172.18.0.59';





  Future<int> receiveData() async {
    var url = Uri.parse('http://$ipAddress/?cmd=a');

    try {
      // Replace with the actual IP address and command
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var responseData = response.body;
        // Process the received data
        log.i('response status code:${response.statusCode}');

        //return 0;
        return int.parse(responseData);
      }


    }
    catch(e){
      log.d('An error occured: $e');

    }

    return espConnectionFailed;
  }

  Future<bool> sendData(String data) async {
    var url = Uri.parse('http://$ipAddress/');
    try {
      log.i('Starting');
      log.i(data);

      var body = {'data':data};

      var response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        // Data sent successfully
        print('Data sent to ESP32');
        return true;
      } else {
        // Request failed
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('An error occurred: $e');

    }

    return false;
  }


  }