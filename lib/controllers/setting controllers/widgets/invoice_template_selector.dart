import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/app_colors.dart';

class InvoiceTemplateSelector extends StatelessWidget {
  final String selectedTemplate;
  final Function(String) onTemplateChanged;

  const InvoiceTemplateSelector({
    Key? key,
    required this.selectedTemplate,
    required this.onTemplateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Invoice Template',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Template options
          _buildTemplateOption(
            context,
            templateNo: 'TEMPLATE_001',
            title: 'Invoice UI 1',
            description: 'Professional invoice with gradient header',
            isSelected: selectedTemplate == 'TEMPLATE_001',
          ),
          const SizedBox(height: 12),
          
          _buildTemplateOption(
            context,
            templateNo: 'TEMPLATE_002',
            title: 'Invoice UI 2',
            description: 'Clean and minimal design',
            isSelected: selectedTemplate == 'TEMPLATE_002',
          ),
          const SizedBox(height: 12),
          
          _buildTemplateOption(
            context,
            templateNo: 'TEMPLATE_003',
            title: 'Invoice UI 3',
            description: 'Modern layout with emphasis on details',
            isSelected: selectedTemplate == 'TEMPLATE_003',
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateOption(
    BuildContext context, {
    required String templateNo,
    required String title,
    required String description,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onTemplateChanged(templateNo),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentColor(context).withValues(alpha: 0.1)
              : AppColors.backgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accentColor(context)
                : AppColors.borderColor(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentColor(context)
                      : AppColors.borderColor(context),
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.accentColor(context)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            
            // Template preview thumbnail
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getTemplateGradient(templateNo),
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          Container(
                            height: 3,
                            color: Colors.grey.shade400,
                            margin: const EdgeInsets.only(bottom: 2),
                          ),
                          Container(
                            height: 3,
                            width: 40,
                            color: Colors.grey.shade400,
                            margin: const EdgeInsets.only(bottom: 2),
                          ),
                          const Spacer(),
                          Container(
                            height: 2,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 2),
                          Container(
                            height: 2,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Template info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getTemplateGradient(String templateNo) {
    switch (templateNo) {
      case 'TEMPLATE_001':
        return [Colors.blue.shade700, Colors.blue.shade500];
      case 'TEMPLATE_002':
        return [Colors.purple.shade700, Colors.purple.shade500];
      case 'TEMPLATE_003':
        return [Colors.teal.shade700, Colors.teal.shade500];
      default:
        return [Colors.blue.shade700, Colors.blue.shade500];
    }
  }
}