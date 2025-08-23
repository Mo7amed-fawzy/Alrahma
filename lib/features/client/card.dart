// helpers/clients_ui_helpers.dart
import 'package:flutter/material.dart';
import 'package:tabea/core/utils/app_colors.dart';
import 'package:tabea/core/utils/custom_text_styles.dart';
import '../../core/models/client_model.dart';

/// تبني TextField عربي جاهز مع RTL
Widget buildTextField({
  required TextEditingController controller,
  required String label,
}) {
  return TextField(
    controller: controller,
    textAlign: TextAlign.right, // الكتابة من اليمين
    decoration: InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      labelStyle: const TextStyle(color: Colors.black87),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
    ),
  );
}

/// تبني Card لكل عميل
Widget buildClientCard({
  required ClientModel client,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  return GestureDetector(
    onTap: onEdit,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryBlue,
            child: Text(
              client.name.isNotEmpty ? client.name[0] : '?',
              style: CustomTextStyles.cairoBold20.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.name, style: CustomTextStyles.cairoBold20),
                const SizedBox(height: 4),
                Text(
                  '${client.phone} • ${client.address}',
                  style: CustomTextStyles.cairoRegular16.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    ),
  );
}

/// تبني Dialog لإضافة أو تعديل عميل مع Cubit integration
Future<void> showClientDialog({
  required BuildContext context,
  required ClientModel initial,
  required bool isNew,
  required Function(ClientModel updated) onSave,
}) {
  final nameCtrl = TextEditingController(text: initial.name);
  final phoneCtrl = TextEditingController(text: initial.phone);
  final addrCtrl = TextEditingController(text: initial.address);

  return showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isNew ? 'إضافة عميل' : 'تعديل العميل',
                style: CustomTextStyles.cairoBold20.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 20),
              buildTextField(controller: nameCtrl, label: 'الاسم'),
              const SizedBox(height: 12),
              buildTextField(controller: phoneCtrl, label: 'الهاتف'),
              const SizedBox(height: 12),
              buildTextField(controller: addrCtrl, label: 'العنوان'),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      textStyle: CustomTextStyles.cairoRegular16,
                    ),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final updated = ClientModel(
                        id: initial.id,
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        address: addrCtrl.text.trim(),
                      );
                      onSave(updated);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'حفظ',
                      style: TextStyle(color: Colors.white),
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
