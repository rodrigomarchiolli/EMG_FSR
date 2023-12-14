import 'package:emg_app/models/exam.dart';
import 'package:emg_app/models/patient.dart';
import 'package:emg_app/models/sample.dart';
import 'package:emg_app/services/isar_database/isar_database.dart';
import 'package:isar/isar.dart';

class IsarDatabaseProd extends IsarDatabase {
  // Abre uma instãncia da base para fazer operações CRUD
  @override
  Future<Isar> openIsar() async {
    final Isar? isar;
    if (Isar.instanceNames.isEmpty) {
      isar = await Isar.open(
        [
          PatientSchema,
          ExamSchema,
          SampleSchema,
        ],
        inspector: true,
      );
    } else {
      isar = Isar.getInstance(Isar.instanceNames.first);
    }

    return isar!;
  }

  @override
  Future<Id> putPatient(Isar isar, Patient patient) async {
    Id id = await isar.writeTxn(() async {
      return await isar.patients.put(patient);
    });
    return id;
  }

  @override
  Future<Patient?> getPatientById(Isar isar, Id id) async {
    final Patient? patient = await isar.patients.get(id);

    return patient;
  }

  @override
  Future<List<Patient>> getAllPatients(Isar isar) async {
    final patients = await isar.patients.where().findAll();
    return patients;
  }

  @override
  Future<bool> deletePatient(Isar isar, Id id) async {
    return await isar.writeTxn(() async {
      return await isar.patients.delete(id).then((deleted) {
        return deleted;
      });
    });
  }

  @override
  Future<List<Exam>> getAllExamsByPatientId(Isar isar, Id id) async {
    final exams = await isar.exams.filter().patientIdEqualTo(id).findAll();
    return exams;
  }

  @override
  Future<Id> putExam(Isar isar, Exam exam) async {
    Id id = await isar.writeTxn(() async {
      return await isar.exams.put(exam);
    });
    return id;
  }

  @override
  Future<bool> deleteExam(Isar isar, Id id) async {
    return await isar.writeTxn(() async {
      return await isar.exams.delete(id).then((deleted) {
        return deleted;
      });
    });
  }

  @override
  Future<Id> putSample(Isar isar, Sample sample) async {
    Id id = await isar.writeTxn(() async {
      return await isar.samples.put(sample);
    });
    return id;
  }

  @override
  Future<List<Sample>> getAllSamplesByExamId(Isar isar, Id id) async {
    final samples = await isar.samples.filter().examIdEqualTo(id).findAll();
    return samples;
  }

  @override
  Future<bool> deleteSample(Isar isar, Id id) async {
    return await isar.writeTxn(() async {
      return await isar.samples.delete(id).then((deleted) {
        return deleted;
      });
    });
  }
}
