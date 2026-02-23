import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:smartbecho/utils/app_colors.dart';

class CommonDropdownSearch<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final String Function(T)? itemAsString;
  final bool Function(T, T)? compareFn;
  final ValueChanged<T?>? onChanged;

  final String labelText;
  final bool enabled;
  final bool showSearch;
  final String hintText;
  final IconData prefixIcon;
  final IconData suffixIcon;

  final FormFieldValidator<T>? validator;
  final FormFieldSetter<T>? onSaved;
  final AutovalidateMode autoValidateMode;

  const CommonDropdownSearch({
    super.key,
    required this.items,
    this.selectedItem,
    this.itemAsString,
    this.compareFn,
    this.onChanged,
    this.labelText = '',
    this.enabled = true,
    this.showSearch = true,
    this.hintText = 'Select an item',
    this.prefixIcon = Icons.category,
    this.suffixIcon = Icons.arrow_drop_down,
    this.validator,
    this.onSaved,
    this.autoValidateMode = AutovalidateMode.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText.isNotEmpty)
          Text(
            labelText,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (labelText.isNotEmpty) const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownSearch<T>(
            items: (filter, loadProps) => items,
            selectedItem: selectedItem,
            itemAsString: itemAsString,
            compareFn: compareFn,
            enabled: enabled,
            autoValidateMode: autoValidateMode,
            popupProps: PopupProps.modalBottomSheet(
              showSearchBox: showSearch,
              modalBottomSheetProps: ModalBottomSheetProps(
                isScrollControlled: true,
                showDragHandle: true,
                backgroundColor: Colors.white,
                enableDrag: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              scrollbarProps: const ScrollbarProps(thumbVisibility: true),
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryLight)
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  prefixIcon,
                  size: 18,
                  color: Colors.grey[600],
                ),
                suffixIcon: Icon(
                  suffixIcon,
                  size: 18,
                  color: Colors.grey[600],
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            validator: validator,
            onSaved: onSaved,
            onChanged: onChanged,
          ),
        ),
        if (validator != null) const SizedBox(height: 6),
      ],
    );
  }
}