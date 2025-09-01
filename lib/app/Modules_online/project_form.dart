import 'package:flutter/material.dart';
import 'package:alrahma/core/services/supabase_services.dart';

class ProjectForm extends StatefulWidget {
  const ProjectForm({super.key});

  @override
  ProjectFormState createState() => ProjectFormState();
}

class ProjectFormState extends State<ProjectForm> {
  String? selectedClient;
  final _type = TextEditingController();
  final _drawing = TextEditingController(); // هنا ممكن تخزن JSON

  List<Map<String, dynamic>> clients = [];

  @override
  void initState() {
    super.initState();
    SupabaseService.getClients().then((data) {
      setState(() => clients = data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Project')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField(
              value: selectedClient,
              items: clients.map((c) {
                return DropdownMenuItem(value: c['id'], child: Text(c['name']));
              }).toList(),
              onChanged: (value) =>
                  setState(() => selectedClient = value as String?),
              decoration: InputDecoration(labelText: 'Client'),
            ),
            TextField(
              controller: _type,
              decoration: InputDecoration(labelText: 'Project Type'),
            ),
            TextField(
              controller: _drawing,
              decoration: InputDecoration(labelText: 'Drawing JSON'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () async {
                if (selectedClient != null) {
                  await SupabaseService.addProject(
                    selectedClient!,
                    _type.text,
                    {"drawing": _drawing.text},
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
