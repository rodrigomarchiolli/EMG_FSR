import 'package:emg_app/screens/panel.dart';
import 'package:emg_app/services/patient_provider.dart';
import 'package:emg_app/services/usb_connection_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PatientProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UsbConnectionProvider(),
        ),
      ],
      child: MaterialApp(
        home: const MyApp(),
        theme: ThemeData(useMaterial3: true),
        debugShowMaterialGrid: false,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    final patientProvider =
        Provider.of<PatientProvider>(context, listen: false);
    final usbConnectionProvider =
        Provider.of<UsbConnectionProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await patientProvider.init();
      await usbConnectionProvider.init();
      if (patientProvider.selectedPatient == null) {
        Future.microtask(
            () => patientProvider.checkForSelectedPatient(context));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    return Builder(
      builder: (BuildContext context) {
        return Scaffold(
          body: patientProvider.selectedPatient == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const Panel(),
        );
      },
    );
  }
}
