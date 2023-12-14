import 'package:emg_app/models/patient.dart';
import 'package:emg_app/services/patient_provider.dart';
import 'package:emg_app/services/usb_connection_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PatientSection extends StatefulWidget {
  final Patient patient;
  const PatientSection({
    super.key,
    required this.patient,
  });

  @override
  State<PatientSection> createState() => _PatientSectionState();
}

class _PatientSectionState extends State<PatientSection> {
  late PatientProvider patientProvider;
  late UsbConnectionProvider usbConnectionProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    patientProvider = Provider.of<PatientProvider>(context);
    usbConnectionProvider = Provider.of<UsbConnectionProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 0, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getPatientActionButtons(context),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paciente', style: textTheme.titleMedium),
                      Text(getPatientName(), style: textTheme.titleLarge),
                      Text(getPatientAge(), style: textTheme.titleSmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 8, 2),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(20, 98, 0, 238),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                          patientProvider.currentExam == null
                              ? ''
                              : patientProvider.currentExam!.name,
                          style: textTheme.titleMedium),
                    ),
                    getExamActionButtons(context),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 0, 2),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(20, 98, 0, 238),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('EMG', style: textTheme.titleMedium),
                    ),
                    getEMGActionButtons(context),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 0, 2),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(20, 98, 0, 238),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('FSR', style: textTheme.titleMedium),
                    ),
                    getFRSActionButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool hasPatient() {
    return patientProvider.selectedPatient != null;
  }

  getPatientActionButtons(BuildContext context) {
    if (hasPatient()) {
      return Row(
        children: [
          Tooltip(
            message: 'Fechar Paciente',
            child: IconButton(
              onPressed: () {
                Provider.of<PatientProvider>(context, listen: false)
                    .clearSelectedPatient();
                Provider.of<PatientProvider>(context, listen: false)
                    .checkForSelectedPatient(context);
              },
              icon: const Icon(
                Icons.close,
                size: 16,
                color: Color.fromARGB(255, 98, 0, 238),
              ),
            ),
          ),
          Tooltip(
            message: 'Editar Paciente',
            child: IconButton(
              onPressed: () {
                patientProvider.showEditPatientDialog(context);
              },
              icon: const Icon(
                Icons.edit,
                size: 16,
                color: Color.fromARGB(255, 98, 0, 238),
              ),
            ),
          ),
          Tooltip(
            message: 'Excluir Paciente',
            child: IconButton(
              onPressed: () async {
                await patientProvider.deletePatient(context).then((_) {
                  Provider.of<PatientProvider>(context, listen: false)
                      .checkForSelectedPatient(context);
                });
              },
              icon: const Icon(
                Icons.delete,
                size: 16,
                color: Color.fromARGB(255, 98, 0, 238),
              ),
            ),
          ),
        ],
      );
    }
  }

  bool hasExam() {
    return patientProvider.currentExam != null;
  }

  getExamActionButtons(BuildContext context) {
    if (hasPatient()) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: 'Novo Exame',
              child: IconButton(
                onPressed: () {
                  patientProvider.createExam();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 98, 0, 238),
                ),
                icon: const Icon(
                  Icons.add_chart,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: 'Renomear Exame',
              child: IconButton(
                onPressed: () {
                  patientProvider.showRenameExamDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 98, 0, 238),
                ),
                icon: const Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: 'Salvar Exame',
              child: IconButton(
                onPressed: () {
                  patientProvider.saveExam();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 98, 0, 238),
                ),
                icon: const Icon(
                  Icons.save,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          /*
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: 'Exportar (PDF)',
              child: IconButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 98, 0, 238),
                ),
                icon: const Icon(
                  Icons.picture_as_pdf,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          */
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: 'Excluir Exame',
              child: IconButton(
                onPressed: () {
                  patientProvider.deleteExam(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 98, 0, 238),
                ),
                icon: const Icon(
                  Icons.delete,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  getEMGActionButtons(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: 'Parear Sensor',
            child: IconButton(
              onPressed: () {
                usbConnectionProvider.showSelectEMGPortDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 98, 0, 238),
              ),
              icon: const Icon(
                Icons.usb,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: 'Calibrar Sensor',
            child: IconButton(
              onPressed: () {
                usbConnectionProvider.requestEMGCalibration(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 98, 0, 238),
              ),
              icon: const Icon(
                Icons.compass_calibration,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: 'Definir Tempo de Medição',
            child: IconButton(
              onPressed: () {
                usbConnectionProvider.setEMGTime(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 98, 0, 238),
              ),
              icon: const Icon(
                Icons.timer,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  getFRSActionButtons(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: 'Parear Sensor',
            child: IconButton(
              onPressed: () {
                usbConnectionProvider.showSelectFSRPortDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 98, 0, 238),
              ),
              icon: const Icon(
                Icons.usb,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: 'Calibrar Sensor',
            child: IconButton(
              onPressed: () {
                usbConnectionProvider.requestFSRCalibration(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 98, 0, 238),
              ),
              icon: const Icon(
                Icons.compass_calibration,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: 'Definir Tempo de Medição',
            child: IconButton(
              onPressed: () {
                usbConnectionProvider.setFSRTime(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 98, 0, 238),
              ),
              icon: const Icon(
                Icons.timer,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String getPatientAge() {
    if (hasPatient()) {
      if (widget.patient.age == 1) {
        return '${widget.patient.age} ano';
      } else {
        return '${widget.patient.age} anos';
      }
    } else {
      return '';
    }
  }

  String getPatientName() {
    if (hasPatient()) {
      return widget.patient.identification;
    } else {
      return 'Selecione o Paciente';
    }
  }
}
