import 'package:emg_app/services/patient_provider.dart';
import 'package:emg_app/services/usb_connection_provider.dart';
import 'package:emg_app/widgets/voltage_sample_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Graph extends StatefulWidget {
  const Graph({super.key});

  @override
  State<Graph> createState() => _GraphState();
}

class _GraphState extends State<Graph> {
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 16, 0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 300,
              maxHeight: viewportConstraints.maxHeight,
            ),
            child: SizedBox(
              width: (MediaQuery.of(context).size.width * 0.75) - 64,
              child: VoltageSampleChart(
                data: patientProvider.graphData,
                color: patientProvider.getCurrentSampleIndex() >= 0
                    ? patientProvider
                        .getColor(patientProvider.getCurrentSampleIndex())
                    : const Color.fromARGB(55, 0, 0, 0),
              ),
            ),
          );
        },
      ),
    );
  }
}
