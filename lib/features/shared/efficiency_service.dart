import 'package:fuel_efficiency_app/core/constants/app_constants.dart';

import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';

import 'package:fuel_efficiency_app/features/shared/app_enums.dart';

/// The metric a chart / analytics view is currently displaying.

enum EfficiencyMetric { mpg, milesPerKwh, costPerDistance }

/// A single point on a trend chart.

class TrendPoint {
  const TrendPoint({
    required this.label,
    required this.value,
    required this.date,
  });

  final String label;

  final double value;

  final DateTime date;
}

/// Aggregate statistics for a set of entries.

class EfficiencyStats {
  const EfficiencyStats({
    required this.average,

    required this.best,

    required this.worst,

    required this.totalDistance,

    required this.totalCost,

    required this.avgCostPerDistance,

    required this.entryCount,
  });

  final double average;

  final double best;

  final double worst;

  final double totalDistance;

  final double totalCost;

  final double avgCostPerDistance;

  final int entryCount;

  bool get hasData => entryCount > 0;

  static const EfficiencyStats empty = EfficiencyStats(
    average: 0,

    best: 0,

    worst: 0,

    totalDistance: 0,

    totalCost: 0,

    avgCostPerDistance: 0,

    entryCount: 0,
  );
}

/// Pure calculation engine for all fuel/charge/hybrid efficiency maths.

///

/// Kept stateless so it is trivial to unit-test and inject via GetX.

class EfficiencyService {
  const EfficiencyService();

  bool _isKilometers(String unit) => unit.toLowerCase().startsWith('k');

  bool _isUsGallons(String volumeUnit) =>
      volumeUnit.toLowerCase().startsWith('g');

  /// Normalises a distance value into miles regardless of the active unit so

  /// MPG / mi-per-kWh stay comparable across the app.

  double toMiles(double distance, String distanceUnit) {
    return _isKilometers(distanceUnit)
        ? distance * AppConstants.milesPerKilometer
        : distance;
  }

  /// Converts a stored volume into imperial gallons for MPG (UK default).

  double toImperialGallons(double volume, String volumeUnit) {
    if (_isUsGallons(volumeUnit)) {
      return volume *
          (AppConstants.usGallonInLitres / AppConstants.imperialGallonInLitres);
    }

    return volume / AppConstants.imperialGallonInLitres;
  }

  /// Miles per (imperial) gallon for a single fuel/hybrid entry.

  double mpg({
    required double distance,

    required double litres,

    required String distanceUnit,

    String volumeUnit = AppConstants.defaultVolumeUnit,
  }) {
    if (litres <= 0 || distance <= 0) return 0;

    final gallons = toImperialGallons(litres, volumeUnit);

    if (gallons <= 0) return 0;

    return toMiles(distance, distanceUnit) / gallons;
  }

  /// Miles travelled per kWh consumed.

  double milesPerKwh({
    required double distance,

    required double kwh,

    required String distanceUnit,
  }) {
    if (kwh <= 0 || distance <= 0) return 0;

    return toMiles(distance, distanceUnit) / kwh;
  }

  double costPerDistance({
    required double totalCost,
    required double distance,
  }) {
    if (distance <= 0) return 0;

    return totalCost / distance;
  }

  /// Per-entry value for the requested metric.

  double metricFor(
    FuelEntryModel entry,

    EfficiencyMetric metric,

    String distanceUnit, {

    String volumeUnit = AppConstants.defaultVolumeUnit,
  }) {
    switch (metric) {
      case EfficiencyMetric.mpg:
        return mpg(
          distance: entry.distance,

          litres: entry.liters,

          distanceUnit: distanceUnit,

          volumeUnit: volumeUnit,
        );

      case EfficiencyMetric.milesPerKwh:
        return milesPerKwh(
          distance: entry.distance,

          kwh: entry.kwh,

          distanceUnit: distanceUnit,
        );

      case EfficiencyMetric.costPerDistance:
        return costPerDistance(
          totalCost: entry.totalCost,

          distance: entry.distance,
        );
    }
  }

  /// Entries that contain meaningful data for the requested metric.

  List<FuelEntryModel> _relevant(
    List<FuelEntryModel> entries,

    EfficiencyMetric metric,
  ) {
    switch (metric) {
      case EfficiencyMetric.mpg:
        return entries.where((e) => e.liters > 0 && e.distance > 0).toList();

      case EfficiencyMetric.milesPerKwh:
        return entries.where((e) => e.kwh > 0 && e.distance > 0).toList();

      case EfficiencyMetric.costPerDistance:
        return entries.where((e) => e.distance > 0).toList();
    }
  }

  EfficiencyStats stats(
    List<FuelEntryModel> entries,

    EfficiencyMetric metric,

    String distanceUnit, {

    String volumeUnit = AppConstants.defaultVolumeUnit,
  }) {
    final relevant = _relevant(entries, metric);

    if (relevant.isEmpty) return EfficiencyStats.empty;

    final values = relevant
        .map((e) => metricFor(e, metric, distanceUnit, volumeUnit: volumeUnit))
        .where((v) => v > 0)
        .toList();

    if (values.isEmpty) return EfficiencyStats.empty;

    final totalDistance = relevant.fold<double>(
      0,
      (sum, e) => sum + e.distance,
    );

    final totalCost = relevant.fold<double>(0, (sum, e) => sum + e.totalCost);

    double average;

    if (metric == EfficiencyMetric.mpg) {
      final totalLitres = relevant.fold<double>(0, (s, e) => s + e.liters);

      average = mpg(
        distance: totalDistance,

        litres: totalLitres,

        distanceUnit: distanceUnit,

        volumeUnit: volumeUnit,
      );
    } else if (metric == EfficiencyMetric.milesPerKwh) {
      final totalKwh = relevant.fold<double>(0, (s, e) => s + e.kwh);

      average = milesPerKwh(
        distance: totalDistance,

        kwh: totalKwh,

        distanceUnit: distanceUnit,
      );
    } else {
      average = costPerDistance(totalCost: totalCost, distance: totalDistance);
    }

    // For cost-per-distance a *lower* value is better, so best/worst must be
    // inverted relative to efficiency metrics (where higher is better).
    final lowerIsBetter = metric == EfficiencyMetric.costPerDistance;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);

    return EfficiencyStats(
      average: average,

      best: lowerIsBetter ? minValue : maxValue,

      worst: lowerIsBetter ? maxValue : minValue,

      totalDistance: totalDistance,

      totalCost: totalCost,

      avgCostPerDistance: costPerDistance(
        totalCost: totalCost,
        distance: totalDistance,
      ),

      entryCount: relevant.length,
    );
  }

  /// Builds a chronological trend series (oldest -> newest) for charting.

  List<TrendPoint> trend(
    List<FuelEntryModel> entries,

    EfficiencyMetric metric,

    String distanceUnit, {

    String volumeUnit = AppConstants.defaultVolumeUnit,

    int? maxPoints,
  }) {
    final relevant = _relevant(entries, metric)
      ..sort((a, b) => a.date.compareTo(b.date));

    var points = relevant
        .map(
          (e) => TrendPoint(
            label: _shortDate(e.date),

            value: metricFor(e, metric, distanceUnit, volumeUnit: volumeUnit),

            date: e.date,
          ),
        )
        .where((p) => p.value > 0)
        .toList();

    if (maxPoints != null && points.length > maxPoints) {
      points = points.sublist(points.length - maxPoints);
    }

    return points;
  }

  /// Weekly buckets (W1..Wn) for dashboard trend cards.

  List<TrendPoint> weeklyTrend(
    List<FuelEntryModel> entries,

    EfficiencyMetric metric,

    String distanceUnit, {

    String volumeUnit = AppConstants.defaultVolumeUnit,

    int weeks = 4,
  }) {
    final relevant = _relevant(entries, metric);

    if (relevant.isEmpty) return const [];

    final now = DateTime.now();

    final points = <TrendPoint>[];

    for (var w = weeks - 1; w >= 0; w--) {
      final weekStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: (w + 1) * 7));

      final weekEnd = weekStart.add(const Duration(days: 7));

      final weekEntries = relevant
          .where((e) => !e.date.isBefore(weekStart) && e.date.isBefore(weekEnd))
          .toList();

      if (weekEntries.isEmpty) continue;

      final stats = this.stats(
        weekEntries,

        metric,

        distanceUnit,

        volumeUnit: volumeUnit,
      );

      points.add(
        TrendPoint(
          label: 'W${weeks - w}',

          value: stats.average,

          date: weekStart,
        ),
      );
    }

    return points;
  }

  /// Percentage of the manufacturer claim that the driver actually achieves.

  double realityPercent(double realValue, double claimedValue) {
    if (claimedValue <= 0 || realValue <= 0) return 0;

    return (realValue / claimedValue) * 100;
  }

  /// Signed difference (real vs claim) as a percentage.

  double differencePercent(double realValue, double claimedValue) {
    if (claimedValue <= 0) return 0;

    return ((realValue - claimedValue) / claimedValue) * 100;
  }

  /// Monthly running cost for the current calendar month.

  double monthlyCost(List<FuelEntryModel> entries) {
    final now = DateTime.now();

    return entries
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0, (sum, e) => sum + e.totalCost);
  }

  /// Monthly distance for the current calendar month.

  double monthlyDistance(List<FuelEntryModel> entries) {
    final now = DateTime.now();

    return entries
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0, (sum, e) => sum + e.distance);
  }

  /// Monthly average cost per distance unit.

  double monthlyCostPerDistance(List<FuelEntryModel> entries) {
    final distance = monthlyDistance(entries);

    if (distance <= 0) return 0;

    return monthlyCost(entries) / distance;
  }

  /// Entries in the current calendar month.

  List<FuelEntryModel> monthlyEntries(List<FuelEntryModel> entries) {
    final now = DateTime.now();

    return entries
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
  }

  /// Potential saving (or loss) vs the manufacturer claim, projected across

  /// the total distance driven.

  double savingsVsClaim({
    required List<FuelEntryModel> entries,

    required double claimedMpg,

    required String distanceUnit,

    String volumeUnit = AppConstants.defaultVolumeUnit,
  }) {
    if (claimedMpg <= 0) return 0;

    final fuelEntries = entries.where((e) => e.liters > 0).toList();

    if (fuelEntries.isEmpty) return 0;

    final totalDistanceMiles = fuelEntries.fold<double>(
      0,

      (sum, e) => sum + toMiles(e.distance, distanceUnit),
    );

    final totalFuelCost = fuelEntries.fold<double>(
      0,
      (sum, e) => sum + e.fuelCost,
    );

    final totalLitres = fuelEntries.fold<double>(0, (sum, e) => sum + e.liters);

    if (totalLitres <= 0) return 0;

    final costPerLitre = totalFuelCost / totalLitres;

    final claimedGallons = totalDistanceMiles / claimedMpg;

    final claimedLitres = claimedGallons * AppConstants.imperialGallonInLitres;

    final claimedCost = claimedLitres * costPerLitre;

    return totalFuelCost - claimedCost;
  }

  /// Extra electricity spend vs manufacturer mi/kWh claim.

  double savingsVsElectricClaim({
    required List<FuelEntryModel> entries,

    required double claimedMiPerKwh,

    required String distanceUnit,
  }) {
    if (claimedMiPerKwh <= 0) return 0;

    final chargeEntries = entries.where((e) => e.kwh > 0).toList();

    if (chargeEntries.isEmpty) return 0;

    final totalDistanceMiles = chargeEntries.fold<double>(
      0,

      (sum, e) => sum + toMiles(e.distance, distanceUnit),
    );

    final totalElectricCost = chargeEntries.fold<double>(
      0,
      (sum, e) => sum + e.electricityCost,
    );

    final totalKwh = chargeEntries.fold<double>(0, (sum, e) => sum + e.kwh);

    if (totalKwh <= 0) return 0;

    final costPerKwh = totalElectricCost / totalKwh;

    final claimedKwh = totalDistanceMiles / claimedMiPerKwh;

    final claimedCost = claimedKwh * costPerKwh;

    return totalElectricCost - claimedCost;
  }

  String _shortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',

      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]}';
  }
}

/// Distance window used by analytics filters.

enum AnalyticsRange {
  week('7D', 7),

  month('30D', 30),

  quarter('90D', 90),

  year('1Y', 365),

  all('All', -1);

  const AnalyticsRange(this.label, this.days);

  final String label;

  final int days;

  bool contains(DateTime date) {
    if (days < 0) return true;

    final cutoff = DateTime.now().subtract(Duration(days: days));

    return date.isAfter(cutoff);
  }
}

extension EnergyMetricX on EnergyMode {
  EfficiencyMetric get primaryMetric {
    switch (this) {
      case EnergyMode.fuel:
        return EfficiencyMetric.mpg;

      case EnergyMode.charge:
        return EfficiencyMetric.milesPerKwh;

      case EnergyMode.hybrid:
        return EfficiencyMetric.costPerDistance;
    }
  }
}
