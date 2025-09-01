import 'package:flutter/material.dart';
import 'package:alrahma/core/services/supabase_services.dart';

class DataList extends StatefulWidget {
  const DataList({super.key});

  @override
  DataListState createState() => DataListState();
}

class DataListState extends State<DataList> {
  List<Map<String, dynamic>> payments = [];

  @override
  void initState() {
    super.initState();
    loadPayments();
  }

  void loadPayments() async {
    final data = await SupabaseService.getPayments();
    setState(() => payments = data);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (_, index) {
        final p = payments[index];
        return ListTile(
          title: Text('Client: ${p['client_id']} Project: ${p['project_id']}'),
          subtitle: Text('Remaining: ${p['remaining_amount']}'),
        );
      },
    );
  }
}
