import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartbecho/utils/app_colors.dart';

Widget buildStyledTextField({
  required String labelText,
  required TextEditingController controller,
  required String hintText,
  String? prefixText,
  String? suffixText,
  Widget? suffixIcon,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
  void Function()? onTap,
  int? maxLines,
  bool readOnly = false,
  bool enabled = true,
  Widget? prefixIcon,
  List<TextInputFormatter>? inputFormatters,
  FocusNode? focusNode,
  bool digitsOnly = false,
  int? maxLength,
    bool obscureText = false,
  TextCapitalization?  textCapitalization,
  String? helperText,
Iterable<String>? autofillHints
}) {
  return Builder(
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(
              color: enabled ? const Color(0xFF374151) : Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            autofillHints:autofillHints ,
            focusNode: focusNode,
            // inputFormatters: inputFormatters
            // ,
            textCapitalization: textCapitalization?? TextCapitalization.words,
              obscureText: obscureText,
            controller: controller,
            keyboardType: keyboardType,
            maxLines: obscureText ? 1 : maxLines,
            readOnly: readOnly,
            enabled: enabled,
            onTap: onTap,
            maxLength: maxLength,
            inputFormatters:
                digitsOnly
                    ? [
                      FilteringTextInputFormatter.digitsOnly,
                      if (maxLength != null)
                        LengthLimitingTextInputFormatter(maxLength),
                    ]
                    : null,

            style: TextStyle(
              color: enabled ? const Color(0xFF374151) : Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              hintText: hintText,
              helperText: helperText,
              hintStyle: TextStyle(
                color: enabled ? const Color(0xFF9CA3AF) : Colors.grey.shade400,
                fontSize: 14,
              ),
              prefixText: prefixText,
              suffixText: suffixText,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey.shade50,

              // ✅ Different border colors for normal, focus & error
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primaryLight, // blue focus color
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.red, // red border on error
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator: validator,
            onChanged: onChanged,
          ),
        ],
      );
    },
  );
}

Widget buildAutocompleteField({
  required String labelText,
  required TextEditingController controller,
  required List<String> suggestions,
  required String hintText,
  TextInputType? keyboardType,
  required Function(String) onChanged,
  String? Function(String?)? validator,
}) {
  // Get suggestions list - this triggers Obx reactivity
  final suggestionsList = suggestions.toList();

  return Autocomplete<String>(
    optionsBuilder: (TextEditingValue textEditingValue) {
      if (textEditingValue.text.isEmpty) {
        return suggestionsList;
      }
      return suggestionsList.where((String option) {
        return option.toLowerCase().contains(
          textEditingValue.text.toLowerCase(),
        );
      });
    },
    onSelected: (String selection) {
      controller.text = selection;
      onChanged(selection);
    },
    fieldViewBuilder: (
      BuildContext context,
      TextEditingController fieldController,
      FocusNode focusNode,
      VoidCallback onFieldSubmitted,
    ) {
      // Sync with the main controller only once
      if (fieldController.text.isEmpty && controller.text.isNotEmpty) {
        fieldController.text = controller.text;
      }

      fieldController.removeListener(() {});
      fieldController.addListener(() {
        if (controller.text != fieldController.text) {
          controller.text = fieldController.text;
          onChanged(fieldController.text);
        }
      });

      return buildStyledTextField(
        labelText: labelText,
        controller: fieldController,
        hintText: hintText,
        keyboardType: keyboardType,
        focusNode: focusNode,
        validator: validator,
      );
    },
    optionsViewBuilder: (
      BuildContext context,
      AutocompleteOnSelected<String> onSelected,
      Iterable<String> options,
    ) {
      return Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final String option = options.elementAt(index);
                return InkWell(
                  onTap: () {
                    onSelected(option);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    child: Text(option, style: const TextStyle(fontSize: 14)),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
