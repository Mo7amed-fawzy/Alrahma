import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:flutter/material.dart';

/// Card للمشروع
Widget buildProjectCard({
  required ProjectModel project,
  required List<ClientModel> clients,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
  required double screenWidth,
}) {
  final clientName = clients
      .firstWhere(
        (c) => c.id == project.clientId,
        orElse: () =>
            ClientModel(id: '', name: 'غير معروف', phone: '', address: ''),
      )
      .name;

  return GestureDetector(
    onTap: onEdit,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(
        vertical: screenWidth * 0.02,
        horizontal: screenWidth * 0.01,
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.2),
            blurRadius: screenWidth * 0.02,
            offset: Offset(0, screenWidth * 0.01),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            child: CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              child: Icon(
                Icons.work_outline,
                color: Colors.white,
                size: screenWidth * 0.06,
              ),
            ),
          ),

          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${project.type} ',
                  style: CustomTextStyles.cairoBold20.copyWith(
                    fontSize: screenWidth * 0.045,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  project.description,
                  style: CustomTextStyles.cairoRegular16.copyWith(
                    color: Colors.grey[700],
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: screenWidth * 0.07,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    ),
  );
}
