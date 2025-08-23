import 'package:flutter/material.dart';
import 'package:tabea/core/services/supabase_services.dart';

class ClientForm extends StatefulWidget {
  const ClientForm({super.key});

  @override
  ClientFormState createState() => ClientFormState();
}

class ClientFormState extends State<ClientForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Client')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phone,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: _address,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () async {
                await SupabaseService.addClient(
                  _name.text,
                  _phone.text,
                  _address.text,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
