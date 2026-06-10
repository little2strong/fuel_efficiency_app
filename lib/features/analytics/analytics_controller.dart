import 'package:get/get.dart';

import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/shared/efficiency_service.dart';

class AnalyticsController extends GetxController {
  AnalyticsController(this._data);

  final AppDataController _data;

  static const metrics = [
    EfficiencyMetric.mpg,
    EfficiencyMetric.milesPerKwh,
    EfficiencyMetric.costPerDistance,
  ];

  final RxInt metricIndex = 0.obs;
  final RxInt rangeIndex = 4.obs; // default "All"

  RxString get currencySymbol => _data.currencySymbol;
  RxString get distanceUnit => _data.distanceUnit;
  RxString get volumeUnit => _data.volumeUnit;
  RxBool get isHydrated => _data.isHydrated;
  bool get hasVehicle => _data.selectedVehicle != null;

  EfficiencyMetric get metric => metrics[metricIndex.value];
  AnalyticsRange get range => AnalyticsRange.values[rangeIndex.value];

  bool get isCostMetric => metric == EfficiencyMetric.costPerDistance;

  void setMetric(int index) => metricIndex.value = index;
  void setRange(int index) => rangeIndex.value = index;

  @override
  void onInit() {
    super.onInit();
    _syncMetricToVehicle();
    ever(_data.selectedVehicleId, (_) => _syncMetricToVehicle());
  }

  void _syncMetricToVehicle() {
    final vehicle = _data.selectedVehicle;
    if (vehicle == null) return;
    final index = metrics.indexOf(vehicle.energyMode.primaryMetric);
    if (index >= 0) metricIndex.value = index;
  }

  List<FuelEntryModel> get _rangedEntries => _data.selectedVehicleEntries
      .where((e) => range.contains(e.date))
      .toList();

  EfficiencyStats get stats => _data.efficiency.stats(
    _rangedEntries,
    metric,
    distanceUnit.value,
    volumeUnit: volumeUnit.value,
  );

  List<TrendPoint> get trendPoints => _data.efficiency.trend(
    _rangedEntries,
    metric,
    distanceUnit.value,
    volumeUnit: volumeUnit.value,
  );

  double get changePercent {
    final points = trendPoints;
    if (points.length < 2) return 0;
    final first = points.first.value;
    final last = points.last.value;
    if (first <= 0) return 0;
    return ((last - first) / first) * 100;
  }

  double get savings => _data.savingsVsClaim;

  String get metricUnit {
    switch (metric) {
      case EfficiencyMetric.mpg:
        return 'MPG';
      case EfficiencyMetric.milesPerKwh:
        return 'mi/kWh';
      case EfficiencyMetric.costPerDistance:
        return 'per ${distanceUnit.value.toLowerCase()}';
    }
  }

  String get metricTitle {
    switch (metric) {
      case EfficiencyMetric.mpg:
        return 'MPG Trend';
      case EfficiencyMetric.milesPerKwh:
        return 'Efficiency Trend';
      case EfficiencyMetric.costPerDistance:
        return 'Cost Trend';
    }
  }
}
