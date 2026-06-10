import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fuel_efficiency_app/core/constants/app_constants.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

/// Result of parsing an imported backup payload.
class ImportPayload {
  const ImportPayload({required this.vehicles, required this.entries});

  final List<VehicleModel> vehicles;
  final List<FuelEntryModel> entries;
}

/// Handles converting the app's data to/from portable JSON & CSV and sharing
/// the resulting files. Fully offline – nothing leaves the device unless the
/// user explicitly shares it.
class DataTransferService {
  const DataTransferService();

  static const String _schemaVersion = '1';

  String buildJson({
    required List<VehicleModel> vehicles,
    required List<FuelEntryModel> entries,
  }) {
    final map = {
      'schema': _schemaVersion,
      'app': AppConstants.appName,
      'exportedAt': DateTime.now().toIso8601String(),
      'vehicles': vehicles.map((v) => v.toJson()).toList(),
      'entries': entries.map((e) => e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  String buildCsv(List<FuelEntryModel> entries) {
    final buffer = StringBuffer()
      ..writeln(
        'id,vehicleId,date,mode,distance,liters,kwh,fuelCost,'
        'electricityCost,totalCost,odometer,fuelGrade,fullTank,note',
      );
    for (final e in entries) {
      buffer.writeln(
        [
          e.id,
          e.vehicleId,
          e.date.toIso8601String(),
          e.mode.storageValue,
          e.distance,
          e.liters,
          e.kwh,
          e.fuelCost,
          e.electricityCost,
          e.totalCost,
          e.odometer,
          _csv(e.fuelGrade ?? ''),
          e.fullTank,
          _csv(e.note ?? ''),
        ].join(','),
      );
    }
    return buffer.toString();
  }

  String _csv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<File> _writeFile(String fileName, String contents) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    return file.writeAsString(contents);
  }

  Future<void> exportJson({
    required List<VehicleModel> vehicles,
    required List<FuelEntryModel> entries,
  }) async {
    final json = buildJson(vehicles: vehicles, entries: entries);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file = await _writeFile('fuel_efficiency_backup_$stamp.json', json);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'Fuel Efficiency backup',
        text: 'Fuel Efficiency data export',
      ),
    );
  }

  Future<void> exportCsv(List<FuelEntryModel> entries) async {
    final csv = buildCsv(entries);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file = await _writeFile('fuel_efficiency_entries_$stamp.csv', csv);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Fuel Efficiency entries',
        text: 'Fuel Efficiency entries export',
      ),
    );
  }

  /// Persists a full backup to local storage and returns the saved path so it
  /// can be surfaced to the user.
  Future<String> saveBackup({
    required List<VehicleModel> vehicles,
    required List<FuelEntryModel> entries,
  }) async {
    final json = buildJson(vehicles: vehicles, entries: entries);
    final file = await _writeFile('fuel_efficiency_latest_backup.json', json);
    return file.path;
  }

  /// Parses a JSON backup string produced by [buildJson].
  ImportPayload parseJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup is not a valid object.');
    }
    final vehiclesRaw = decoded['vehicles'] as List<dynamic>? ?? [];
    final entriesRaw = decoded['entries'] as List<dynamic>? ?? [];
    final vehicles = vehiclesRaw
        .map((v) => VehicleModel.fromJson(Map<String, dynamic>.from(v as Map)))
        .toList();
    final entries = entriesRaw
        .map(
          (e) => FuelEntryModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
    return ImportPayload(vehicles: vehicles, entries: entries);
  }
}
