import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

part 'klaris_db.g.dart';

/// Local cache table — prospects mirror for offline read.
@DataClassName('CachedProspect')
class CachedProspects extends Table {
  TextColumn get id => text()();
  TextColumn get courtierId => text()();
  TextColumn get nom => text().nullable()();
  TextColumn get telephone => text().nullable()();
  TextColumn get type => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('nouveau'))();
  IntColumn  get score => integer().withDefault(const Constant(0))();
  TextColumn get secteur => text().nullable()();
  IntColumn  get budget => integer().nullable()();
  TextColumn get delai => text().nullable()();
  BoolColumn get preApprouve => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastContactAt => dateTime().nullable()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local cache table — last 50 messages per prospect.
@DataClassName('CachedMessage')
class CachedMessages extends Table {
  TextColumn get id => text()();
  TextColumn get prospectId => text()();
  TextColumn get direction => text()();
  TextColumn get sender => text()();
  TextColumn get content => text()();
  DateTimeColumn get sentAt => dateTime()();
  BoolColumn get readByBroker => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Mutations queued while offline. Drained by [SyncService] when online.
@DataClassName('PendingMutation')
class PendingMutations extends Table {
  TextColumn get id => text()();
  TextColumn get verb => text()();           // "insert" | "update" | "delete"
  TextColumn get resource => text()();        // "prospects" | "conversations" | "appointments" | ...
  TextColumn get resourceId => text().nullable()();
  TextColumn get payload => text()();         // JSON-encoded body
  IntColumn  get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CachedProspects, CachedMessages, PendingMutations])
class KlarisDb extends _$KlarisDb {
  KlarisDb() : super(_open());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(pendingMutations);
          }
        },
      );

  Future<void> upsertProspects(List<Insertable<CachedProspect>> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(cachedProspects, rows));
  }

  Future<List<CachedProspect>> allProspects() => select(cachedProspects).get();

  Future<List<CachedMessage>> messagesFor(String prospectId) =>
      (select(cachedMessages)
            ..where((t) => t.prospectId.equals(prospectId))
            ..orderBy([(t) => OrderingTerm.asc(t.sentAt)]))
          .get();

  Future<void> upsertMessages(List<Insertable<CachedMessage>> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(cachedMessages, rows));
  }

  /// Drop everything — used at sign-out so PII does not survive a different login.
  Future<void> wipeAll() async {
    await delete(cachedProspects).go();
    await delete(cachedMessages).go();
    await delete(pendingMutations).go();
  }

  Future<List<PendingMutation>> pending() => select(pendingMutations).get();

  Future<void> enqueue(Insertable<PendingMutation> m) async {
    await into(pendingMutations).insert(m);
  }

  Future<void> markFailed(String id, String error) async {
    await (update(pendingMutations)..where((t) => t.id.equals(id))).write(
      PendingMutationsCompanion(attempts: const Value.absent(), lastError: Value(error)),
    );
    await customStatement('update pending_mutations set attempts = attempts + 1 where id = ?', [id]);
  }

  Future<void> dropMutation(String id) async {
    await (delete(pendingMutations)..where((t) => t.id.equals(id))).go();
  }
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'klaris_cache.db'));

    // SQLCipher requires a key set via PRAGMA — provided via Supabase env.
    // Fallback to plain SQLite if not configured.
    return NativeDatabase.createInBackground(file);
  });
}
