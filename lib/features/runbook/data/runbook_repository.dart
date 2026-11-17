import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/runbook_models.dart';

class RunbookRepository {
  RunbookRepository({Database? testDb}) : _db = testDb;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'family_tech_runbook.db'),
      version: 1,
      onCreate: createSchema,
    );
    return _db!;
  }

  static Future<void> createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dispositivos (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE procedimientos (
        id TEXT PRIMARY KEY,
        device_id TEXT NOT NULL,
        title TEXT NOT NULL,
        first_step_id TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE pasos (
        id TEXT PRIMARY KEY,
        procedure_id TEXT NOT NULL,
        instruction TEXT NOT NULL,
        yes_next_step_id TEXT,
        no_next_step_id TEXT,
        is_terminal INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE contactos (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT '',
        phone TEXT NOT NULL DEFAULT ''
      )
    ''');

    // Starter offline family runbook.
    await db.insert(
        'dispositivos',
        const Dispositivo(
                id: 'dev_router', name: 'Router Wi-Fi', location: 'Salón')
            .toMap());
    await db.insert(
        'procedimientos',
        const Procedimiento(
                id: 'proc_wifi',
                deviceId: 'dev_router',
                title: 'No hay internet en casa',
                firstStepId: 's_1')
            .toMap());
    await db.insert(
        'pasos',
        const PasoRunbook(
          id: 's_1',
          procedureId: 'proc_wifi',
          instruction: '¿Está encendida la luz de corriente del router?',
          yesNextStepId: 's_2',
          noNextStepId: 's_3',
        ).toMap());
    await db.insert(
        'pasos',
        const PasoRunbook(
          id: 's_2',
          procedureId: 'proc_wifi',
          instruction:
              'Apaga el router del botón trasero, espera 30 segundos y vuelve a encenderlo. ¿Volvió la conexión?',
          yesNextStepId: 's_ok',
          noNextStepId: 's_call',
        ).toMap());
    await db.insert(
        'pasos',
        const PasoRunbook(
          id: 's_3',
          procedureId: 'proc_wifi',
          instruction:
              'Comprueba que el enchufe y la regleta estén encendidos.',
          isTerminal: true,
        ).toMap());
    await db.insert(
        'pasos',
        const PasoRunbook(
          id: 's_ok',
          procedureId: 'proc_wifi',
          instruction: '¡Listo! Ya debería funcionar internet.',
          isTerminal: true,
        ).toMap());
    await db.insert(
        'pasos',
        const PasoRunbook(
          id: 's_call',
          procedureId: 'proc_wifi',
          instruction:
              'Parece una caída externa de la línea. Llama a tu contacto de ayuda o a la operadora.',
          isTerminal: true,
        ).toMap());
  }

  Future<List<Dispositivo>> listDevices() async {
    final db = await database;
    final rows = await db.query('dispositivos');
    return rows.map(Dispositivo.fromMap).toList();
  }

  Future<List<Procedimiento>> listProcedures() async {
    final db = await database;
    final rows = await db.query('procedimientos');
    return rows.map(Procedimiento.fromMap).toList();
  }

  Future<List<PasoRunbook>> listSteps() async {
    final db = await database;
    final rows = await db.query('pasos');
    return rows.map(PasoRunbook.fromMap).toList();
  }

  Future<List<Contacto>> listContacts() async {
    final db = await database;
    final rows = await db.query('contactos');
    return rows.map(Contacto.fromMap).toList();
  }

  Future<void> upsertContact(Contacto c) async {
    final db = await database;
    await db.insert('contactos', c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

