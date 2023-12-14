import 'package:isar/isar.dart';
part 'sample.g.dart';

@Collection()
class Sample {
  Id id;
  int examId;
  String name;
  double value;
  String filePath;

  Sample(
    this.examId,
    this.name,
    this.value,
    this.filePath, {
    Id? id,
  }) : id = id ?? Isar.autoIncrement;
}
