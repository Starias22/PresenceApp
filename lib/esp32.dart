import 'package:http/http.dart' as http;
import 'package:presence_app/utils.dart';
class ESP32
{
  //final String ipAddress='172.16.65.1';//wireless cpp
   //final String ipAddress='172.16.64.202';//wireless cpp
  //final String ipAddress='172.16.64.254';//wireless cpp
    //final String ipAddress='172.18.0.59';
  //final String ipAddress='172.18.0.72';
     final String ipAddress='172.18.0.214';//jem
  //final String ipAddress='192.168.1.173';//jem

  // final String ipAddress='172.16.64.202';//public wireless


    //http://192.168.1.172/?cmd=a //jem

//http://172.16.65.1/?cmd=a //wireless ccpccp
  //http://172.16.64.202/?cmd=a //wireless ccp
  Future<int> receiveData() async {
    if ( !await utils.netWorkAvailable()) {

      return noInternetConnection;
    }
    var url = Uri.parse('http://$ipAddress/?cmd=a');
    log.i('Receive data');

    try {
      log.i('Receive data****');
      // Replace with the actual IP address and command
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var responseData = response.body;
        // Process the received data
        //log.i('response status code:${response.statusCode}');

        //return 0;
        log.d('response: $responseData');

        return int.parse(responseData);
      }
    }
    catch(e){
      log.d('An error occurred: $e');

    }
    return espConnectionFailed;
  }

  Future<bool> sendData(String data) async {
    var url = Uri.parse('http://$ipAddress/');
    try {
      var body = {'data':data};

      var response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        // Data sent successfully

        return true;
      } else {
        // Request failed
      }
    } catch (e) {

//
    }
    return false;
  }
}
