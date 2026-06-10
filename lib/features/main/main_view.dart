import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/core/widgets/app_bottom_nav.dart';
import 'package:fuel_efficiency_app/features/analytics/analytics_view.dart';
import 'package:fuel_efficiency_app/features/history/history_view.dart';
import 'package:fuel_efficiency_app/features/home/home_view.dart';
import 'package:fuel_efficiency_app/features/main/main_controller.dart';
import 'package:fuel_efficiency_app/features/more/more_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    const tabs = [DashboardTab(), HistoryTab(), AnalyticsTab(), MoreTab()];

    return Scaffold(
      body: Obx(
        () => IndexedStack(index: controller.tabIndex.value, children: tabs),
      ),
      bottomNavigationBar: Obx(
        () => AppBottomNav(
          currentIndex: controller.tabIndex.value,
          onTabSelected: controller.changeTab,
          onAddPressed: controller.openAddEntry,
        ),
      ),
    );
  }
}
