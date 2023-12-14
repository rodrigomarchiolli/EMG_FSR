import 'package:emg_app/models/patient.dart';
import 'package:emg_app/services/patient_provider.dart';
import 'package:emg_app/widgets/patient_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectPatient extends StatefulWidget {
  const SelectPatient({super.key});

  @override
  State<SelectPatient> createState() => _SelectPatientState();
}

class _SelectPatientState extends State<SelectPatient> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    final patientProvider =
        Provider.of<PatientProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return Stack(
                        children: [
                          Container(
                            height: constraints.maxHeight,
                            color: const Color.fromARGB(255, 98, 0, 238),
                          ),
                          FutureBuilder<List<Patient>>(
                            future: patientProvider.getAllPatients(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.white,
                                ));
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                    child: Text(
                                  'Quando houver pacientes cadastrados,\neles irão aparecer aqui.',
                                  style: textTheme.bodyLarge!.merge(
                                    const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ));
                              }
                              return SingleChildScrollView(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 16, 16, 0),
                                        child: Text(
                                          'Pacientes',
                                          style: textTheme.titleLarge!.merge(
                                            const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Tooltip(
                                          message: 'Exportar Pacientes',
                                          child: IconButton(
                                            onPressed: () {
                                              patientProvider
                                                  .exportCSVDataBaseFile(
                                                      context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                            ),
                                            icon: const Icon(
                                              Icons.cloud_download,
                                              size: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ...snapshot.data!.map((patient) {
                                        return PatientCard(
                                          patient: patient,
                                          onTap: () {
                                            patientProvider
                                                .selectPatient(patient);
                                            Navigator.pop(context);
                                          },
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Cadastrar Novo Paciente',
                              style: textTheme.titleLarge),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _identifierController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Informe o identificador do paciente.';
                                      }
                                      return null;
                                    },
                                    style: textTheme.bodyMedium,
                                    decoration: const InputDecoration(
                                      labelText: 'Identificador do Paciente',
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 8.0),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 32,
                                  ),
                                  TextFormField(
                                    controller: _ageController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Informe a idade paciente.';
                                      }
                                      return null;
                                    },
                                    style: textTheme.bodyMedium,
                                    decoration: const InputDecoration(
                                      labelText: 'Idade do Paciente',
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 8.0),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 42,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          final patient = Patient(
                                            _identifierController.text,
                                            int.parse(_ageController.text),
                                          );
                                          patientProvider
                                              .putPatient(patient)
                                              .then((id) {
                                            patientProvider
                                                .getPatient(context, id)
                                                .then((newPatient) {
                                              patientProvider
                                                  .selectPatient(newPatient);
                                              Navigator.pop(context);
                                            });
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 98, 0, 238),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          'Cadastrar',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 18,
            right: 18,
            child: Image.asset(
              'assets/images/emg_logo.png',
              height: 32,
            ),
          ),
        ],
      ),
    );
  }
}
