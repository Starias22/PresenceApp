
void main(){
  var list=subdivideDateTimeInterval(DateTime(2000,1,1,14),
      DateTime(2000,1,1,18) , 8);

print('the list: $list');
}
List<List<DateTime>> subdivideDateTimeInterval
    (DateTime inf, DateTime sup, int num) {
  Duration interval = sup.difference(inf) ~/ num;
  List<DateTime> result = [];

  for (int i = 0; i < num; i++) {
    DateTime dateTime = inf.add(interval * i);
    result.add(dateTime);
  }
  result.add(sup);

  print('The result $result');

  List<List<DateTime>> intervalBounds = [];

  for (int i = 0; i < result.length - 1; i++) {
    List<DateTime> bounds = [result[i], result[i + 1]];
    intervalBounds.add(bounds);
  }


  return intervalBounds;
}

