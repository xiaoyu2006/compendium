import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CompendiumEntry {
  final String imageBase64;
  final String wikipediaEntry; // Primary key
  final double bboxUpperLeftX;
  final double bboxUpperLeftY;
  final double bboxLowerRightX;
  final double bboxLowerRightY;
  final int recordTimestamp;

  CompendiumEntry({
    required this.imageBase64,
    required this.wikipediaEntry,
    required this.bboxUpperLeftX,
    required this.bboxUpperLeftY,
    required this.bboxLowerRightX,
    required this.bboxLowerRightY,
    required this.recordTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'image_base64': imageBase64,
      'wikipedia_entry': wikipediaEntry,
      'bbox_upper_left_x': bboxUpperLeftX,
      'bbox_upper_left_y': bboxUpperLeftY,
      'bbox_lower_right_x': bboxLowerRightX,
      'bbox_lower_right_y': bboxLowerRightY,
      'record_timestamp': recordTimestamp,
    };
  }

  static Future<CompendiumEntry> fromResponse(Map<String, dynamic> map, String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final imageBase64 = base64Encode(bytes);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return CompendiumEntry(
      imageBase64: imageBase64,
      wikipediaEntry: map['name'],
      bboxUpperLeftX: map['x1'],
      bboxUpperLeftY: map['y1'],
      bboxLowerRightX: map['x2'],
      bboxLowerRightY: map['y2'],
      recordTimestamp: timestamp,
    );
  }
}

class CompendiumDBManager {
  static final CompendiumDBManager _instance = CompendiumDBManager._internal();
  factory CompendiumDBManager() => _instance;

  static Database? _db;

  CompendiumDBManager._internal();

  Future<Database> get db async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    return openDatabase(
      join(await getDatabasesPath(), 'compendium.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE compendium_entries('
          'image_base64 TEXT NOT NULL,'
          'wikipedia_entry TEXT PRIMARY KEY,'
          'bbox_upper_left_x REAL NOT NULL,'
          'bbox_upper_left_y REAL NOT NULL,'
          'bbox_lower_right_x REAL NOT NULL,'
          'bbox_lower_right_y REAL NOT NULL,'
          'record_timestamp INTEGER NOT NULL'
          ')',
        );
      },
      version: 1,
    );
  }

  // Also use this to update entries
  Future<int> insert(CompendiumEntry entry) async {
    final Database db = await _instance.db;
    return db.insert(
      'compendium_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CompendiumEntry>> entries() async {
    final Database db = await _instance.db;
    final List<Map<String, dynamic>> maps = await db.query('compendium_entries');
    return List.generate(maps.length, (i) {
      return CompendiumEntry(
        imageBase64: maps[i]['image_base64'],
        wikipediaEntry: maps[i]['wikipedia_entry'],
        bboxUpperLeftX: maps[i]['bbox_upper_left_x'],
        bboxUpperLeftY: maps[i]['bbox_upper_left_y'],
        bboxLowerRightX: maps[i]['bbox_lower_right_x'],
        bboxLowerRightY: maps[i]['bbox_lower_right_y'],
        recordTimestamp: maps[i]['record_timestamp'],
      );
    });
  }
}
