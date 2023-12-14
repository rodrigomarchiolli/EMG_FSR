import 'package:emg_app/models/sample.dart';
import 'package:emg_app/services/patient_provider.dart';
import 'package:emg_app/services/usb_connection_provider.dart';
import 'package:emg_app/widgets/sample_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Samples extends StatefulWidget {
  const Samples({Key? key}) : super(key: key);

  @override
  State<Samples> createState() => _SamplesState();
}

class _SamplesState extends State<Samples> {
  final ScrollController _scrollController = ScrollController();
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: (MediaQuery.of(context).size.width * 0.75) - 32,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Tooltip(
                      message: 'Importar Amostra',
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            patientProvider.importSample(context);
                          },
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60.0),
                              color: const Color.fromARGB(255, 98, 0, 238),
                            ),
                            child: const Icon(
                              Icons.upload_file,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Tooltip(
                      message: 'Nova Amostra',
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            patientProvider.createSample();
                          },
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60.0),
                              color: const Color.fromARGB(255, 98, 0, 238),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Consumer<PatientProvider>(
                    builder: (context, patientProvider, child) {
                      List<Sample> samples = patientProvider.examSamples;

                      if (samples.isNotEmpty) {
                        return Row(
                          children: samples.map((sample) {
                            return GestureDetector(
                                onTap: () {
                                  patientProvider.setCurrentSample(
                                    sample,
                                    usbConnectionProvider,
                                  );
                                },
                                child: SampleCard(
                                  sample: sample,
                                  color: patientProvider
                                      .getColor(samples.indexOf(sample)),
                                ));
                          }).toList(),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _scrollController.animateTo(
                      _scrollController.offset - (140 + 16),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: null,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _scrollController.animateTo(
                      _scrollController.offset + (140 + 16),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
