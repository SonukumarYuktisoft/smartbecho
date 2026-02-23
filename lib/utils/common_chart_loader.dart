//common chart loader widget

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/generic_charts.dart';
import 'package:smartbecho/views/dashboard/charts/switchable_chart.dart';
import 'package:smartbecho/views/dashboard/widgets/dashboard_shimmers.dart';
import 'package:smartbecho/views/dashboard/widgets/error_cards.dart';

Widget commonChartloader({
  required Map<String, double> chartData,
  required RxBool chartError,
  required RxBool isChartLoaded,
  required RxBool chartHasError,
  required String chartTitle,
  required RxString chartErrorMessage,
  required ChartDataType chartDataType,
  required bool isSmallScreen
}) {
  return Obx(
    () =>
        isChartLoaded.value
            ? GenericBarChartShimmer(title: chartTitle)
            : chartHasError.value
            ? buildErrorCard(chartErrorMessage, Get.width, Get.height, true)
            : SwitchableChartWidget(
              payload: chartData,
              title: chartTitle,
              screenWidth: Get.width,
              screenHeight: Get.width,
              isSmallScreen:isSmallScreen,
              initialChartType: "barchart", // Start with bar chart
              chartDataType: chartDataType,
            ),
  );
}
