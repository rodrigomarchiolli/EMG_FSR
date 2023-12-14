import 'package:emg_app/models/exam.dart';
import 'package:emg_app/models/patient.dart';
import 'package:emg_app/models/sample.dart';
import 'package:isar/isar.dart';

abstract class IsarDatabase {
  Future<Isar> openIsar();

  Future<Id> putPatient(Isar isar, Patient patient);

  Future<Patient?> getPatientById(Isar isar, Id id);

  Future<List<Patient>> getAllPatients(Isar isar);

  Future<bool> deletePatient(Isar isar, Id id);

  Future<List<Exam>> getAllExamsByPatientId(Isar isar, Id id);

  Future<Id> putExam(Isar isar, Exam exam);

  Future<bool> deleteExam(Isar isar, Id id);

  Future<Id> putSample(Isar isar, Sample sample);

  Future<List<Sample>> getAllSamplesByExamId(Isar isar, Id id);

  Future<bool> deleteSample(Isar isar, Id id);
}
