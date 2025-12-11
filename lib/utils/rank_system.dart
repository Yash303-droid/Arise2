class RankSystem {
  static const List<String> _rankNames = [
    'Iron I',
    'Iron II',
    'Iron III',
    'Bronze I',
    'Bronze II',
    'Bronze III',
    'Silver I',
    'Silver II',
    'Silver III',
    'Gold I',
    'Gold II',
    'Gold III',
    'Platinum I',
    'Platinum II',
    'Platinum III',
    'Diamond I',
    'Diamond II',
    'Diamond III',
    'Master',
    'Grandmaster',
  ];

  static String getRank(int level) {
    if (level <= 0) {
      return _rankNames[0];
    }
    // Assuming 5 levels per rank tier
    int rankIndex = (level - 1) ~/ 5;
    if (rankIndex >= _rankNames.length) {
      return _rankNames.last;
    }
    return _rankNames[rankIndex];
  }
}
