class Company{
late String name,email,country,id;
String? pictureDownloadUrl;
Company({this.id='', required this.name,required this.email,
  required this.country,this.pictureDownloadUrl});

Map<String, dynamic> toMap() => {

  'name':name,
  'email': email,
  'country': country,
  'picture_download_url':pictureDownloadUrl
};

static Company fromMap(Map<String, dynamic> map) {
  return Company(

      id: map['id'],
      email: map['email'],
      name: map['name'],
      country: map['country'],
      pictureDownloadUrl: map['picture_download_url']
  );
}
}
