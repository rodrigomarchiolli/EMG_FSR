import 'package:emg_app/models/patient.dart';
import 'package:flutter/material.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;
  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(
          patient.identification,
        ),
        subtitle: Text(
          getPatientAge(),
        ),
        leading: const Icon(
          Icons.person,
          color: Colors.black,
        ),
        onTap: onTap,
      ),
    );
  }

  String getPatientAge() {
    if (patient.age == 1) {
      return '${patient.age} ano';
    } else {
      return '${patient.age} anos';
    }
  }
}
