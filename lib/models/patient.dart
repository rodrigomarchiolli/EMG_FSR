import 'package:isar/isar.dart';
part 'patient.g.dart';

@Collection()
class Patient {
  Id id;
  String identification;
  int age;

  Patient(
    this.identification,
    this.age, {
    Id? id,
  }) : id = id ?? Isar.autoIncrement;
}
