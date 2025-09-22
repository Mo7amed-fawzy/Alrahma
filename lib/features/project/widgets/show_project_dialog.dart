import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:flutter/material.dart';

Future<void> showProjectDialog({
  required BuildContext context,
  required ProjectModel initial,
  required bool isNew,
  required List<ClientModel> clients,
  required Function(ProjectModel updated) onSave,
  ClientModel? fixedClient,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final typeCtrl = TextEditingController(text: initial.type);
  final descCtrl = TextEditingController(text: initial.description);
  String selectedClientId = fixedClient?.id ?? initial.clientId;
  final _formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isNew ? 'إضافة مشروع' : 'تعديل المشروع',
                style: CustomTextStyles.cairoBold20.copyWith(
                  color: AppColors.primaryBlue,
                  fontSize: screenWidth * 0.05,
                ),
              ),
              SizedBox(height: screenWidth * 0.05),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (fixedClient != null)
                      // 👇 عرض اسم العميل فقط
                      Text(
                        fixedClient.name,
                        style: CustomTextStyles.cairoBold20.copyWith(
                          fontSize: screenWidth * 0.045,
                          color: Colors.black87,
                        ),
                      )
                    else
                      // Dropdown لاختيار العميل
                      DropdownButtonFormField<String>(
                        value: selectedClientId.isEmpty && clients.isNotEmpty
                            ? clients.first.id
                            : selectedClientId,
                        items: clients
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  c.name,
                                  style: CustomTextStyles.cairoRegular16
                                      .copyWith(fontSize: screenWidth * 0.04),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => selectedClientId = v ?? '',
                        decoration: InputDecoration(
                          labelText: 'العميل',
                          labelStyle: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Colors.black87,
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'الرجاء اختيار العميل'
                            : null,
                      ),
                    SizedBox(height: screenWidth * 0.03),

                    // نوع المشروع
                    TextFormField(
                      controller: typeCtrl,
                      decoration: InputDecoration(
                        labelText: 'النوع',
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: Colors.black87,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'الرجاء إدخال النوع'
                          : null,
                    ),
                    SizedBox(height: screenWidth * 0.03),

                    // وصف المشروع
                    TextFormField(
                      controller: descCtrl,
                      decoration: InputDecoration(
                        labelText: 'الوصف',
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: Colors.black87,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'الرجاء إدخال الوصف'
                          : null,
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenWidth * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      textStyle: TextStyle(fontSize: screenWidth * 0.043),
                    ),
                    child: const Text('إلغاء'),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final updated = ProjectModel(
                          id: initial.id,
                          clientId: selectedClientId,
                          type: typeCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          createdAt: initial.createdAt,
                        );
                        onSave(updated);

                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenWidth * 0.035,
                      ),
                    ),
                    child: Text(
                      'حفظ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
