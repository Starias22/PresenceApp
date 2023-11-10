class Company{
late String name,email,country,city,id;
late String? otherLocation;
bool subscribeStatus=false;
String? pictureDownloadUrl;
Company({this.id='', required this.name,required this.email,
  required this.country,this.pictureDownloadUrl, required this.city,
  this.otherLocation,
  required this.subscribeStatus});

Map<String, dynamic> toMap() => {

  'name':name,
  'email': email,
  'country': country,
  'city': city,
  'other_location': otherLocation,
  'subscribe_status': subscribeStatus,
  'picture_download_url':pictureDownloadUrl
};

static Company fromMap(Map<String, dynamic> map) {
  return Company(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      country: map['country'],
      pictureDownloadUrl: map['picture_download_url'],
      city: map['city'],
      subscribeStatus: map['subscribe_status'],
      otherLocation: map['other_location'],

  );
}
}
