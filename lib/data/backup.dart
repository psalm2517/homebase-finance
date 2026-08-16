import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import 'database.dart';

/// What a backup file contains, read without applying it — so a restore can
/// be confirmed before anything is destroyed.
class BackupSummary {
  const BackupSummary({
    required this.exportedAt,
    required this.schemaVersion,
    required this.profileNames,
    required this.profileIds,
    required this.rowCounts,
  });

  final DateTime exportedAt;
  final int schemaVersion;
  final List<String> profileNames;
  final List<int> profileIds;

  /// Table name to row count, for showing what is about to come back.
  final Map<String, int> rowCounts;

  int get totalRows =>
      rowCounts.values.fold(0, (sum, count) => sum + count);
}

class BackupException implements Exception {
  BackupException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Exports and restores Homebase data as JSON.
///
/// JSON rather than a copy of the SQLite file for three reasons: it can be
/// scoped to one profile (the file cannot, since tables are not partitioned
/// by profile), it stays readable if you ever need to check or fix a value
/// by hand, and it carries its schema version so an older backup can still
/// be understood after the schema moves on.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  /// Bumped only if the file layout itself changes, independently of the
  /// database schema version.
  static const formatVersion = 1;

  /// Tables in dependency order: parents before children. Restoring walks
  /// this forwards and deletes walk it backwards, so foreign keys hold at
  /// every step.
  List<({String name, TableInfo table})> get _tables => [
        (name: 'profiles', table: _db.profiles),
        (name: 'accounts', table: _db.accounts),
        (name: 'creditCards', table: _db.creditCards),
        (name: 'loans', table: _db.loans),
        (name: 'bills', table: _db.bills),
        (name: 'billPayments', table: _db.billPayments),
        (name: 'paycheckSchedules', table: _db.paycheckSchedules),
        (name: 'paychecks', table: _db.paychecks),
        (name: 'paycheckAllocations', table: _db.paycheckAllocations),
        (name: 'budgetEntries', table: _db.budgetEntries),
        (name: 'budgetTargets', table: _db.budgetTargets),
        (name: 'categoryRules', table: _db.categoryRules),
        (name: 'creditScoreSnapshots', table: _db.creditScoreSnapshots),
        (name: 'payments', table: _db.payments),
        (name: 'netWorthSnapshots', table: _db.netWorthSnapshots),
        (name: 'goals', table: _db.goals),
      ];

  /// Serializes every row visible to [profileIds]. Passing a single id is
  /// what a non-admin export does; an admin backing up the household passes
  /// every profile.
  Future<String> exportJson({required List<int> profileIds}) async {
    final data = <String, dynamic>{};

    for (final entry in _tables) {
      final rows = await _db
          .customSelect(
            'SELECT * FROM ${entry.table.actualTableName} '
            'WHERE ${entry.name == 'profiles' ? 'id' : 'profile_id'} '
            'IN (${profileIds.join(',')})',
            readsFrom: {entry.table},
          )
          .get();
      data[entry.name] = [for (final row in rows) row.data];
    }

    final profileRows = (data['profiles'] as List).cast<Map<String, Object?>>();

    return const JsonEncoder.withIndent('  ').convert({
      'homebase': {
        'formatVersion': formatVersion,
        'schemaVersion': _db.schemaVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'profiles': [
          for (final p in profileRows)
            {'id': p['id'], 'name': p['name']},
        ],
      },
      'data': data,
    });
  }

  /// Reads a backup without applying it.
  BackupSummary inspect(String json) {
    late final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      throw BackupException('That file is not valid JSON.');
    }

    final header = decoded['homebase'];
    final data = decoded['data'];
    if (header is! Map || data is! Map) {
      throw BackupException(
          'That does not look like a Homebase backup file.');
    }
    final format = header['formatVersion'];
    if (format is! int || format > formatVersion) {
      throw BackupException(
          'This backup was written by a newer version of Homebase '
          '(format $format). Update Homebase and try again.');
    }

    final profiles = (header['profiles'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    if (profiles.isEmpty) {
      throw BackupException('That backup contains no profiles.');
    }

    return BackupSummary(
      exportedAt:
          DateTime.tryParse(header['exportedAt'] as String? ?? '') ??
              DateTime.now(),
      schemaVersion: header['schemaVersion'] as int? ?? 0,
      profileNames: [for (final p in profiles) p['name'] as String],
      profileIds: [for (final p in profiles) p['id'] as int],
      rowCounts: {
        for (final entry in data.entries)
          entry.key.toString(): (entry.value as List).length,
      },
    );
  }

  /// Replaces the data for every profile in the backup, then inserts the
  /// backup's rows. Anything belonging to those profiles that is not in the
  /// backup is gone — that is what replace means, and the caller is expected
  /// to have said so and taken a safety copy first.
  ///
  /// [allowedProfileIds] guards the visibility rule: a non-admin restoring a
  /// file that happens to contain other profiles must not resurrect them.
  Future<void> restore(
    String json, {
    List<int>? allowedProfileIds,
  }) async {
    final summary = inspect(json);
    if (summary.schemaVersion > _db.schemaVersion) {
      throw BackupException(
          'This backup came from a newer database (v${summary.schemaVersion}) '
          'than this copy of Homebase understands (v${_db.schemaVersion}).');
    }

    final decoded = jsonDecode(json) as Map<String, dynamic>;
    final data = (decoded['data'] as Map).cast<String, dynamic>();

    final targetIds = allowedProfileIds == null
        ? summary.profileIds
        : summary.profileIds
            .where(allowedProfileIds.contains)
            .toList();
    if (targetIds.isEmpty) {
      throw BackupException(
          'That backup does not contain data for this profile.');
    }

    await _db.transaction(() async {
      // Clear children before parents.
      for (final entry in _tables.reversed) {
        final column = entry.name == 'profiles' ? 'id' : 'profile_id';
        await _db.customStatement(
          'DELETE FROM ${entry.table.actualTableName} '
          'WHERE $column IN (${targetIds.join(',')})',
        );
      }

      // Then insert parents before children.
      for (final entry in _tables) {
        final rows =
            (data[entry.name] as List? ?? []).cast<Map<String, dynamic>>();
        final idColumn = entry.name == 'profiles' ? 'id' : 'profile_id';
        // Only write columns this version of the table actually has. A
        // backup from an older schema can carry columns since renamed or
        // dropped (statement_day became statement_close_day), and inserting
        // those verbatim would fail — losing the whole restore over a
        // column that no longer matters.
        final known = {for (final c in entry.table.$columns) c.name};
        for (final row in rows) {
          if (!targetIds.contains(row[idColumn])) continue;
          final columns =
              row.keys.where(known.contains).toList();
          final placeholders = List.filled(columns.length, '?').join(', ');
          await _db.customInsert(
            'INSERT INTO ${entry.table.actualTableName} '
            '(${columns.join(', ')}) VALUES ($placeholders)',
            variables: [
              for (final c in columns) Variable(row[c]),
            ],
          );
        }
      }
    });
  }

  /// Copies the live database file next to itself before a restore, so a
  /// mistaken restore is recoverable. Returns the copy's path, or null if
  /// the database is in memory (tests).
  Future<String?> writeSafetyCopy() async {
    final path = await _db.databasePath;
    if (path == null) return null;
    final source = File(path);
    if (!source.existsSync()) return null;
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final target = '$path.before-restore-$stamp.bak';
    await source.copy(target);
    return target;
  }
}
