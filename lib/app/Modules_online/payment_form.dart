import 'package:flutter/material.dart';
import 'package:tabea/core/services/supabase_services.dart';

class PaymentForm extends StatefulWidget {
  const PaymentForm({super.key});

  @override
  PaymentFormState createState() => PaymentFormState();
}

class PaymentFormState extends State<PaymentForm> {
  String? selectedClient;
  String? selectedProject;
  final _amountPaid = TextEditingController();
  final _totalAmount = TextEditingController();

  List<Map<String, dynamic>> clients = [];
  List<Map<String, dynamic>> projects = [];

  @override
  void initState() {
    super.initState();
    SupabaseService.getClients().then((data) => setState(() => clients = data));
  }

  void loadProjects(String clientId) async {
    final data = await SupabaseService.getProjectsByClient(clientId);
    setState(() => projects = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField(
              // returns object
              value: selectedClient,
              items: clients
                  .map(
                    (c) => DropdownMenuItem(
                      value: c['id'],
                      child: Text(c['name']),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedClient = value as String?;
                  selectedProject = null;
                  loadProjects(value!);
                });
              },
              decoration: InputDecoration(labelText: 'Client'),
            ),
            DropdownButtonFormField(
              value: selectedProject,
              items: projects
                  .map(
                    (p) => DropdownMenuItem(
                      value: p['id'],
                      child: Text(p['type']),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => selectedProject = value as String?),
              decoration: InputDecoration(labelText: 'Project'),
            ),
            TextField(
              controller: _amountPaid,
              decoration: InputDecoration(labelText: 'Amount Paid'),
            ),
            TextField(
              controller: _totalAmount,
              decoration: InputDecoration(labelText: 'Total Amount'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () async {
                if (selectedClient != null && selectedProject != null) {
                  await SupabaseService.addPayment(
                    selectedClient!,
                    selectedProject!,
                    double.parse(_amountPaid.text),
                    double.parse(_totalAmount.text),
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
