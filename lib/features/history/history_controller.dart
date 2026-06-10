import 'package:get/get.dart';

import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/core/utils/formatters.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/main/main_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';

/// Filter applied to the History list. `null` mode == all entries.
class HistoryFilter {
  const HistoryFilter(this.label, this.mode);
  final String label;
  final EnergyMode? mode;
}

class EntryGroup {
  const EntryGroup({required this.label, required this.entries});
  final String label;
  final List<FuelEntryModel> entries;
}

class HistoryController extends GetxController {
  HistoryController(this._data);

  final AppDataController _data;

  static const filters = [
    HistoryFilter('All Entries', null),
    HistoryFilter('Fuel', EnergyMode.fuel),
    HistoryFilter('Charge', EnergyMode.charge),
    HistoryFilter('Hybrid', EnergyMode.hybrid),
  ];

  final RxInt filterIndex = 0.obs;

  RxString get currencySymbol => _data.currencySymbol;
  RxString get distanceUnit => _data.distanceUnit;
  RxString get volumeUnit => _data.volumeUnit;
  RxBool get isHydrated => _data.isHydrated;
  bool get hasVehicle => _data.selectedVehicle != null;

  void setFilter(int index) => filterIndex.value = index;

  List<FuelEntryModel> get _filtered {
    final mode = filters[filterIndex.value].mode;
    final entries = _data.selectedVehicleEntries;
    if (mode == null) return entries;
    return entries.where((e) => e.mode == mode).toList();
  }

  int get entryCount => _filtered.length;

  /// Entries grouped by friendly date label (Today / Yesterday / date).
  List<EntryGroup> get groups {
    final entries = _filtered;
    final map = <String, List<FuelEntryModel>>{};
    for (final entry in entries) {
      final key = Formatters.relativeGroup(entry.date);
      map.putIfAbsent(key, () => []).add(entry);
    }
    final sortedKeys = map.keys.toList()
      ..sort((a, b) {
        final dateA = map[a]!.first.date;
        final dateB = map[b]!.first.date;
        return dateB.compareTo(dateA);
      });
    return sortedKeys
        .map((key) => EntryGroup(label: key, entries: map[key]!))
        .toList();
  }

  void openEntry(FuelEntryModel entry) =>
      Get.toNamed(AppRoutes.entryDetail, arguments: entry);

  void addEntry() => Get.find<MainController>().openAddEntry();
}
