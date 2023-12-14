import 'package:isar/isar.dart';
part 'exam.g.dart';

@Collection()
class Exam {
  Id id;
  int patientId;
  String name;
  DateTime date;

  Exam(
    this.patientId,
    this.name,
    this.date, {
    Id? id,
  }) : id = id ?? Isar.autoIncrement;
}
