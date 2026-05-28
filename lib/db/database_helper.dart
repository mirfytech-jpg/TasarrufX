import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static DatabaseHelper get instance => _instance;
  DatabaseHelper._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'tasarruf_x.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // v1→v2: 'not' sütunu (SQLite anahtar kelimesi) 'aciklama' olarak yeniden adlandırıldı.
        // En kolay yol: tabloları sil ve yeniden oluştur (fresh install'da zaten veri yok).
        await db.execute('DROP TABLE IF EXISTS varliklar');
        await db.execute('DROP TABLE IF EXISTS giderler');
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE varliklar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ad TEXT NOT NULL,
        kategori TEXT NOT NULL,
        deger REAL NOT NULL,
        aciklama TEXT,
        eklenmeTarihi TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE giderler (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ad TEXT NOT NULL,
        tutar REAL NOT NULL,
        kategori TEXT NOT NULL
      )
    ''');
  }

  // ─── Varlık CRUD ─────────────────────────────────────────────────────────

  Future<List<Varlik>> varliklarGetir() async {
    final d = await db;
    final rows = await d.query('varliklar', orderBy: 'eklenmeTarihi DESC');
    return rows.map(Varlik.fromMap).toList();
  }

  Future<void> varlikEkle(Varlik v) async {
    final d = await db;
    await d.insert('varliklar', v.toMap());
  }

  Future<void> varlikGuncelle(Varlik v) async {
    final d = await db;
    await d.update('varliklar', v.toMap(), where: 'id = ?', whereArgs: [v.id]);
  }

  Future<void> varlikSil(int id) async {
    final d = await db;
    await d.delete('varliklar', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Gider CRUD ──────────────────────────────────────────────────────────

  Future<List<Gider>> giderleriGetir() async {
    final d = await db;
    final rows = await d.query('giderler', orderBy: 'ad ASC');
    return rows.map(Gider.fromMap).toList();
  }

  Future<void> giderEkle(Gider g) async {
    final d = await db;
    await d.insert('giderler', g.toMap());
  }

  Future<void> giderGuncelle(Gider g) async {
    final d = await db;
    await d.update('giderler', g.toMap(), where: 'id = ?', whereArgs: [g.id]);
  }

  Future<void> giderSil(int id) async {
    final d = await db;
    await d.delete('giderler', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Tümünü Sil ──────────────────────────────────────────────────────────

  Future<void> tumVerileriSil() async {
    final d = await db;
    await d.delete('varliklar');
    await d.delete('giderler');
  }
}
