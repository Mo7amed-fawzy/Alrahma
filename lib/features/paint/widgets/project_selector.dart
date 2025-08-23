import 'package:flutter/material.dart';
import 'package:tabea/core/models/project_model.dart';
import 'package:tabea/features/paint/cubit/drawing_canvas_cubit.dart';

class ProjectSelector extends StatelessWidget {
  final DrawingCanvasCubit cubit;
  final List<ProjectModel> projects;
  final String selectedProjectId;

  const ProjectSelector({
    super.key,
    required this.cubit,
    required this.projects,
    required this.selectedProjectId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: DropdownButtonFormField<String>(
        value: selectedProjectId,
        items: projects
            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.type)))
            .toList(),
        onChanged: (v) => cubit.changeProject(v ?? projects.first.id),
        decoration: InputDecoration(
          labelText: "اختر المشروع",
          labelStyle: const TextStyle(color: Colors.orange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.orange),
          ),
        ),
      ),
    );
  }
}
