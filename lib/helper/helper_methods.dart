// return a formatted date as a string

import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(Timestamp timestamp) {
  // timestamp is the object we retrieve from the firebase
  // so to display lets convert into string
  DateTime dateTime = timestamp.toDate();

  // year
  String year = dateTime.year.toString();

  // month
  String month = dateTime.month.toString();

  // day
  String day = dateTime.day.toString();

  // final formatted date

  String formattedData = '$day/$month/$year';

  return formattedData;
}
