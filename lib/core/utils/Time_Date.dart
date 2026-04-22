import 'package:intl/intl.dart';

String formatIsoDateForUI(String isoDate) {
  try {
    DateTime utcDateTime = DateTime.parse(isoDate);
    DateTime localDateTime = utcDateTime.toLocal();
    return DateFormat("dd/MM/yyyy, h:mm a", "en_US").format(localDateTime);
  } catch (e) {
    return "-";
  }
}
