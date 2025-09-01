import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alrahma/core/utils/print_statement.dart';

final supabase = Supabase.instance.client;

abstract class SupabaseService {
  static Future<void> addClient(
    String name,
    String phone,
    String address,
  ) async {
    final response = await supabase.from('clients').insert({
      'name': name,
      'phone': phone,
      'address': address,
    });

    if (response.error != null) {
      printHere('Error adding client: ${response.error!.message}');
    } else {
      printHere('Client added: ${response.data}');
    }
  }

  static Future<void> addPayment(
    String clientId,
    String projectId,
    double amountPaid,
    double totalAmount,
  ) async {
    final response = await supabase.from('payments').insert({
      'client_id': clientId,
      'project_id': projectId,
      'amount_paid': amountPaid,
      'total_amount': totalAmount,
    });

    if (response.error != null) {
      printHere('Error adding payment: ${response.error!.message}');
    } else {
      printHere('Payment added: ${response.data}');
    }
  }

  static Future<void> addProject(
    String clientId,
    String type,
    Map<String, dynamic> drawing,
  ) async {
    final response = await supabase.from('projects table').insert({
      'client_id': clientId,
      'type': type,
      'drawing_data': drawing,
    });

    if (response.error != null) {
      printHere('Error adding project: ${response.error!.message}');
    } else {
      printHere('Project added: ${response.data}');
    }
  }

  static Future<List<Map<String, dynamic>>> getPayments() async {
    final data = await supabase.from('payments').select();
    return (data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> getClients() async {
    final data = await supabase.from('clients').select();
    return (data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> getProjectsByClient(
    String clientId,
  ) async {
    final data = await supabase
        .from('projects table')
        .select()
        .eq('client_id', clientId);
    return (data as List<dynamic>).cast<Map<String, dynamic>>();
  }
}
