class DataService{
  String service;
  double poucent;
  String serviceColor;

  DataService(this.service, this.poucent, this.serviceColor);
}

List<DataService> data(){
  final List<DataService> pieData = [
    new DataService("Comptabilité", 20, "green"),
    new DataService("Direction", 10, "bleu"),
    new DataService("Secrétariat Administratif", 15, "red"),
    new DataService("Service coopération", 35, "orange"),
    new DataService("Service scolarité", 30, "indigo")
  ];
  return pieData;
}