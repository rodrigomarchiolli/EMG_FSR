import 'package:emg_app/models/patient.dart';
import 'package:emg_app/services/patient_provider.dart';
import 'package:emg_app/widgets/graph.dart';
import 'package:emg_app/widgets/history.dart';
import 'package:emg_app/widgets/patient.dart';
import 'package:emg_app/widgets/samples.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Panel extends StatefulWidget {
  const Panel({
    super.key,
  });

  @override
  State<Panel> createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  late PatientProvider patientProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    patientProvider = Provider.of<PatientProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: constraints.maxWidth * 0.75,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          PatientSection(
                            patient: Patient(
                              patientProvider.selectedPatient!.identification,
                              patientProvider.selectedPatient!.age,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: 300,
                              maxHeight: constraints.maxHeight <= 681
                                  ? 300
                                  : constraints.maxHeight - 381,
                            ),
                            child: const Graph(),
                          ),
                          const SizedBox(height: 10),
                          const Samples(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth * 0.25,
                    child:
                        History(patientId: patientProvider.selectedPatient!.id),
                  ),
                ],
              ),
            );
          }),
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
