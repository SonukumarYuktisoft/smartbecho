import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/state_manager.dart';
import 'package:smartbecho/utils/app_colors.dart';

class CommonSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final bool activeFilters;
  final VoidCallback? clearFilters;
  final RxString searchQuery;
  final String? hintText;
  final void Function()? onTap;
  final void Function()? onFilter;
  final void Function()? onExport;
  final void Function()? onScan;
  final void Function(String)? onFieldSubmitted;
  final bool? hasFilters;
  final bool? readOnly;
  final bool? hasExport;
  final bool? hasScanner;
 final TextInputType? keyboardType;
  CommonSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    this.activeFilters = false,
    this.onChanged,
    this.clearFilters,
    this.hintText,
    this.onTap,
    this.onFilter,
    this.onFieldSubmitted,
    this.onExport,
    this.onScan,
    this.hasFilters = true,
    this.hasExport = false,
    this.hasScanner = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 12, 16, 12),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFCFD8F9), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search Icon
            Icon(Icons.search_rounded, color: Color(0xFF9DB4CE), size: 26),

            SizedBox(width: 12),

            // Search Field
            Expanded(
              child: TextFormField(
                onTap: onTap,
                onFieldSubmitted: onFieldSubmitted,
                keyboardType:keyboardType ,

                readOnly: readOnly ?? false,
                textAlignVertical: TextAlignVertical.center,
                controller: controller,
                onChanged: (value) {
                  searchQuery.value = value;
                  onChanged?.call(value);
                },

                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hintText ?? 'Search',

                  hintStyle: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFBFD3E6),
                    fontWeight: FontWeight.w400,
                  ),
                  suffixIcon: Obx(
                    () =>
                        searchQuery.isNotEmpty
                            ? IconButton(
                              onPressed: () {
                                searchQuery.value = '';
                                controller.clear();
                                clearFilters?.call();
                              },
                              icon: Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: Color(0xFF9DB4CE),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            )
                            : SizedBox.shrink(),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 0,
                  ),
                ),
              ),
            ),
            if (hasExport ?? false) ...[
              IconButton(
                onPressed: onExport,

                icon: Icon(
                  Icons.upload_file_outlined,
                  size: 24,
                  color:
                      activeFilters
                          ? AppColors.primaryLight
                          : Color(0xFF9DB4CE),
                ),
              ),
            ],
            if (hasScanner ?? false) ...[
              IconButton(
                onPressed: onScan,

                icon: Icon(
                  Icons.camera_alt_outlined,
                  size: 24,
                  color:
                      activeFilters
                          ? AppColors.primaryLight
                          : Color(0xFF9DB4CE),
                ),
              ),
            ],

            // Filter Button
            if (hasFilters ?? true) ...[
              IconButton(
                onPressed: onFilter,

                icon: Icon(
                  Icons.tune_rounded,
                  size: 24,
                  color:
                      activeFilters
                          ? AppColors.primaryLight
                          : Color(0xFF9DB4CE),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
