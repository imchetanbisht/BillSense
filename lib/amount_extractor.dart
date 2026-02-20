class AmountExtractor {

  static double extractAmount(String text) {

    final regex = RegExp(r'(\d+\.?\d{0,2})');

    Iterable<Match> matches = regex.allMatches(text);

    double highest = 0;

    for (var m in matches) {

      double value = double.tryParse(m.group(0) ?? "0") ?? 0;

      if (value > highest && value < 100000) {
        highest = value;
      }
    }

    return highest == 0 ? 100 : highest;
  }
}
