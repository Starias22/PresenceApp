
import 'package:presence_app/utils.dart';

void main() {

  log.i(EStatus);
  log.i(EStatus.values);
  log.i(EStatus.absent);
  log.i(EStatus.values.asMap());
  log.i(EStatus.absent.toString());
  log.i(EStatus.absent.toString().split('.')[1]);
  log.i(EStatus.values.last);
  log.i(utils.str(EStatus.late));

}

