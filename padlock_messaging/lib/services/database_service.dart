/* 
    Padlock Messaging Project
    Copyright (C) <2026>  <Padlock Messaging>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import 'dart:math';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static const _keyAlias = 'db_encryption_key';
  static const _dbName = 'session.db';
  static const _tableSession = 'session';

  static final _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Database? _db;

  // ─── Encryption Key ───────────────────────────────────────────────

  /// Generates a random AES-128 key (16 bytes → base64 string).
  /// SQLCipher accepts a passphrase, so we use base64 as the key string.
  static String _generateKey() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return base64UrlEncode(bytes);
  }

  /// Returns the existing key from secure storage, or generates and stores one.
  static Future<String> _getOrCreateKey() async {
    String? key = await _secureStorage.read(key: _keyAlias);
    if (key == null) {
      key = _generateKey();
      await _secureStorage.write(key: _keyAlias, value: key);
    }
    return key;
  }

  // ─── Database Init ────────────────────────────────────────────────

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final encryptionKey = await _getOrCreateKey();
    final dbPath = join(await getDatabasesPath(), _dbName);

    return await openDatabase(
      dbPath,
      password: encryptionKey,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE $_tableSession (
        access_token TEXT NOT NULL,
        refresh_token TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
      },
    );
  }

  // ─── Session CRUD ─────────────────────────────────────────────────

  /// Inserts a new session, replacing any existing one.
  static Future<void> insertSession({
    required String accessToken,
    required String refreshToken,
  }) async {
    final db = await database;
    await db.delete(_tableSession); // only one session at a time
    await db.insert(_tableSession, {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    });
  }

  /// Returns the stored session or null if none exists.
  static Future<Map<String, String>?> getSession() async {
    final db = await database;
    final rows = await db.query(_tableSession, limit: 1);
    if (rows.isEmpty) return null;
    return {
      'access_token': rows.first['access_token'] as String,
      'refresh_token': rows.first['refresh_token'] as String,
    };
  }

  /// Wipes the session — call on logout.
  static Future<void> clearSession() async {
    final db = await database;
    await db.delete(_tableSession);
  }

  /// Closes the DB connection — call when app is disposed if needed.
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}