class SmartPrinterFields {
  static const String tableName = 'printer';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String intType = 'INTEGER NOT NULL';
  ////////////
  // static const bool id = false;
  static const String id = "_id";
  static const String title = "title";
  static const String isConnected = "is_connected";
  static const String createdTime = 'created_time';

  static const List<String> values = [
    id,
    // number,
    title,
    // content,
    // isFavorite,
    isConnected,
    createdTime,
  ];
}
