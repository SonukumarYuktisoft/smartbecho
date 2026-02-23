import 'package:flutter/material.dart';
import 'package:smartbecho/utils/helper/confirmation/range_confirmation_sheet.dart';

void quantityConfirmationHelper({
  required TextEditingController controller,
  required FocusNode focusNode,
  String? title,
   String? message,
  double softLimit = 100,
}) {
  focusNode.addListener(() {
    if (!focusNode.hasFocus) {
      final value = double.tryParse(controller.text) ?? 0;

      if (value > softLimit) {
        showConfirmationBottomSheet(
          title: title ?? 'Quantity Confirmation',
          message: "You are entering ${value} units. Please confirm if this is correct.",
          highlightedValue: value.toString(),
          onEdit: () {
            focusNode.requestFocus();
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
          },
          onContinue: () {},
        );
      }
    }
  });
}

void priceConfirmationHelper({
  required TextEditingController controller,
  required FocusNode focusNode,
   String ? title,
   String? message,
  double min = 5,
  double softLimit = 200,
}) {
  focusNode.addListener(() {
    if (!focusNode.hasFocus) {
      final value = double.tryParse(controller.text) ?? 0;

      if (value < min || value > softLimit) {
        showConfirmationBottomSheet(
          title: title?? "Price Confirmation",
          message: "You are entering a price of ${value}. Please confirm if this is correct.",
          highlightedValue: value.toString(),
          onEdit: () {
            focusNode.requestFocus();
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
          },
          onContinue: () {},
        );
      }
    }
  });
}
