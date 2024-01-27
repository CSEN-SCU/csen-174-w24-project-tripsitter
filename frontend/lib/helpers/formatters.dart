extension DurationFormat on Duration {
  String format() {
    // format: 1h 2m
    String hours = this.inHours.toString();
    String minutes = (this.inMinutes % 60).toString();
    return "$hours h $minutes m";
  }
}