import 'package:alrahma/core/funcs/init_and_load_databases.dart';
import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/models/payment_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/core/utils/cache_keys.dart';

Future<Map<String, int>> loadHomeStats() async {
  final clients = await DatabasesNames.clientsPrefs.getModels(
    CacheKeys.clientsStorageKey,
    (json) => ClientModel.fromJson(json),
  );

  final projects = await DatabasesNames.projectsPrefs.getModels(
    CacheKeys.projectsKey,
    (json) => ProjectModel.fromJson(json),
  );

  final payments = await DatabasesNames.paymentsPrefs.getModels(
    CacheKeys.paymentsPrefsKey,
    (json) => PaymentModel.fromJson(json),
  );

  return {
    'clients': clients.length,
    'projects': projects.length,
    'payments': payments.length,
  };
}
