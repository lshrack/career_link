import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'main.dart';

// database table and column names
final String tablePeople = 'people';
final String columnId = '_id';
final String columnName = 'name';
final String columnProfession = 'profession';
final String columnEmail = 'email';
final String columnPhone = 'phone';
final String columnCompany = 'company';
final String columnEducation = 'education';

//All of the basic database methods:
//read(db, id), readAll(db), save(entry, db), clearAll(db), deleteItem(id, db),
//editItem(db, entry), getId(db, entry), readAllAsPerson(db)

class DatabaseMethods {
  static read(PersonDatabaseHelper helper, int rowId) async {
    PersonEntry entry = await helper.queryEntry(rowId);

    if (entry == null) {
    } else {
      return entry;
    }
  }

  static Future<List<PersonEntry>> readAll(PersonDatabaseHelper helper) async {
    List<PersonEntry> entries = await helper.queryAllEntries();

    if (entries != null) {
      return entries;
    } else {}

    return [];
  }

  static Future<int> save(
      PersonEntry entry, PersonDatabaseHelper helper) async {
    int id = await helper.insert(entry);
    return id;
  }

  static clearAll(PersonDatabaseHelper helper) async {
    helper.deleteAllEntries();
  }

  static deleteItem(int id, PersonDatabaseHelper helper) async {
    await helper.deleteEntry(id);

    await readAll(helper);
  }

  static editItem(PersonDatabaseHelper helper, PersonEntry entry) async {
    await helper.update(entry);
    await readAll(helper);
  }

  static Future<int> getId(
      PersonDatabaseHelper helper, PersonEntry item) async {
    List<PersonEntry> entries = await readAll(helper);
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].toMap()[columnName] == item.name &&
          entries[i].toMap()[columnProfession] == item.profession &&
          entries[i].toMap()[columnCompany] == item.company &&
          entries[i].toMap()[columnEmail] == item.email &&
          entries[i].toMap()[columnPhone] == item.phone &&
          entries[i].toMap()[columnEducation] == item.education) {
        return entries[i].id;
      }
    }
    return -1;
  }

  static Future<List<Person>> readAllAsPerson(
      PersonDatabaseHelper helper) async {
    List<PersonEntry> entries = await readAll(helper);
    List<Person> people = [];
    PersonEntry curr;

    for (int i = 0; i < entries.length; i++) {
      curr = entries[i];
      people.add(curr.toPerson());
    }

    return people;
  }
}

//******************************************************************************\\
//Person Class
//******************************************************************************\\

class PersonEntry {
  int id;
  String name;
  String profession;
  String phone;
  String company;
  String education;
  String email;

  PersonEntry();
  PersonEntry.withParams(
      {this.id,
      this.name,
      this.profession,
      this.phone,
      this.company,
      this.education,
      this.email});

  //takes map and makes it into a ProjectEntry
  PersonEntry.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    print("Hi, profession is $profession");
    print("Hi, the value in the map is ${map[columnProfession]}");
    profession = map[columnProfession];
    phone = map[columnPhone];
    company = map[columnCompany];
    email = map[columnEmail];
    education = map[columnEducation];
  }

  //makes map out of ProjectEntry
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnName: name,
      columnProfession: profession,
      columnPhone: phone,
      columnCompany: company,
      columnEmail: email,
      columnEducation: education,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  //creates String for debug output
  @override
  String toString() {
    return '$id ' + name + 'Email: $email, \nPhone Number: $phone';
  }

  Person toPerson() {
    return Person(
      id: id,
      name: name == "NULLVAL" ? "" : name,
      profession: profession == "NULLVAL" ? "" : profession,
      email: email == "NULLVAL" ? "" : email,
      phoneNumber: phone == "NULLVAL" ? "" : phone,
      company: company == "NULLVAL" ? "" : company,
      education: education == "NULLVAL" ? "" : education,
    );
  }
}

//************************************************************************************************\\
//HELPER FOR ITEM DATABASE
//************************************************************************************************\\

class PersonDatabaseHelper {
  //Change name when restructuring db; changing version doesn't seem to work
  static final _databaseName = "PersonDatabase1.db";
  static final _databaseVersion = 1;

  PersonDatabaseHelper._privateConstructor();
  static final PersonDatabaseHelper instance =
      PersonDatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) _database.close();
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    // Open the database
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tablePeople (
                $columnId INTEGER PRIMARY KEY,
                $columnName TEXT NOT NULL,
                $columnProfession  TEXT NOT NULL,
                $columnEmail TEXT NOT NULL,
                $columnPhone TEXT NOT NULL,
                $columnEducation TEXT NOT NULL,
                $columnCompany TEXT NOT NULL
              )
              ''');
  }

  //Database helper methods:
  //insert(entry), queryEntry(id), queryAllEntries(), deleteAllEntries(),
  //deleteEntry(id), update(entry)
  Future<int> insert(PersonEntry item) async {
    Database db = await database;
    int id = await db.insert(tablePeople, item.toMap());
    return id;
  }

  Future<PersonEntry> queryEntry(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tablePeople,
        columns: [
          columnId,
          columnName,
          columnProfession,
          columnEducation,
          columnCompany,
          columnPhone,
          columnEmail
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return PersonEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<List<PersonEntry>> queryAllEntries() async {
    Database db = await database;
    List<Map> maps = await db.query(tablePeople);

    if (maps.length == 0) {
      return [];
    }

    List<PersonEntry> items = [PersonEntry.fromMap(maps.first)];

    for (int i = 1; i < maps.length; i++) {
      items.add(PersonEntry.fromMap(maps[i]));
    }

    return items;
  }

  Future<void> deleteAllEntries() async {
    List<PersonEntry> items = await queryAllEntries();

    if (items != null) {
      items.forEach((item) {
        deleteEntry(item.id);
      });
    }

    await queryAllEntries();
  }

  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete(tablePeople, where: "$columnId = ?", whereArgs: [id]);
  }

  Future<void> update(PersonEntry entry) async {
    final db = await database;
    await db.update(tablePeople, entry.toMap(),
        where: "$columnId = ?", whereArgs: [entry.id]);
  }
}
