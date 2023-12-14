import 'package:emg_app/services/isar_database/isar_database.dart';
import 'package:emg_app/services/isar_database/isar_database_prod.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

setupServiceLocator() {
  getIt.registerLazySingleton<IsarDatabase>(() => IsarDatabaseProd());
}
