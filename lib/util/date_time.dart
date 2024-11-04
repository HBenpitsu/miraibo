DateTime today() {
  var now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime farPast() {
  return DateTime(2000);
}
