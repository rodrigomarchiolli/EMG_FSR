import 'dart:io';
import 'dart:math';

import 'package:emg_app/models/exam.dart';
import 'package:emg_app/models/sample.dart';
import 'package:emg_app/screens/select_patient.dart';
import 'package:emg_app/services/isar_database/isar_database.dart';
import 'package:emg_app/services/isar_database/isar_database_prod.dart';
import 'package:emg_app/services/usb_connection_provider.dart';
import 'package:emg_app/widgets/voltage_sample_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:emg_app/models/patient.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class PatientProvider extends ChangeNotifier {
  Patient? _selectedPatient;
  Exam? _currentExam;
  List<Exam> _patientExams = [];
  Sample? _currentSample;
  List<Sample> _examSamples = [];
  List<VoltageSample> graphData = [];
  List<Color> graphLineColor = [
    const Color.fromARGB(255, 255, 69, 0), // Vermelho Laranja
    const Color.fromARGB(255, 0, 128, 0), // Verde Escuro
    const Color.fromARGB(255, 255, 215, 0), // Ouro
    const Color.fromARGB(255, 239, 42, 148), // Rosa Profundo
    const Color.fromARGB(255, 0, 0, 255), // Azul
    const Color.fromARGB(255, 255, 105, 180), // Rosa Quente
    const Color.fromARGB(255, 0, 191, 255), // Azul Céu Profundo
    const Color.fromARGB(255, 0, 255, 127), // Verde Primavera
    const Color.fromARGB(255, 165, 42, 42), // Marrom
    const Color.fromARGB(255, 128, 0, 128), // Roxo
  ];

  bool _showingDialog = false;
  late Isar _isar;
  final IsarDatabase _db = IsarDatabaseProd();

  PatientProvider() {
    _selectedPatient = null;
  }

  Patient? get selectedPatient => _selectedPatient;

  List<Exam> get patientExams => _patientExams;

  IsarDatabase get db => _db;

  Exam? get currentExam => _currentExam;

  Sample? get currentSample => _currentSample;

  List<Sample> get examSamples => _examSamples;

  final ValueNotifier<String> fileNameNotifier = ValueNotifier('');

  final ValueNotifier<String> dataBaseMessage = ValueNotifier('');

  Color getColor(int index) {
    if (index < graphLineColor.length) {
      return graphLineColor[index];
    } else {
      Random random = Random();
      Color randomColor = Color.fromARGB(
        255,
        random.nextInt(256), // Red
        random.nextInt(256), // Green
        random.nextInt(256), // Blue
      );

      graphLineColor.add(randomColor);

      return randomColor;
    }
  }

  int getCurrentSampleIndex() =>
      _examSamples.indexWhere((sample) => sample == _currentSample);

  Future<Id> putPatient(Patient patient) async {
    Id id = await _db.putPatient(_isar, patient);
    notifyListeners();
    return id;
  }

  Future<Patient> getPatient(BuildContext context, Id id) async {
    return await _db.getPatientById(_isar, id).then((patient) {
      if (patient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Paciente não encontrado. Por favor, tente novamente.'),
            duration: Duration(seconds: 5),
          ),
        );
        throw Exception('Paciente não encontrado. Por favor, tente novamente.');
      }
      return patient;
    });
  }

  Future<List<Patient>> getAllPatients() async {
    return await _db.getAllPatients(_isar);
  }

  Future<void> deletePatient(BuildContext context) async {
    if (_selectedPatient != null) {
      bool? shouldDelete = await showDeletionConfirmationDialog(
          context, _selectedPatient!.identification, 'Paciente');
      if (shouldDelete!) {
        await getAllExamsByPatientId(_selectedPatient!.id).then((exams) async {
          for (var exam in exams) {
            await getAllSamplesByExamId(exam.id).then((samples) async {
              for (var sample in samples) {
                await _db.deleteSample(_isar, sample.id);
              }
            }).then((_) async {
              await _db.deleteExam(_isar, exam.id);
            });
          }
        }).then((_) async {
          _currentExam = null;
          _patientExams = [];
          _examSamples = [];
          await _db.deletePatient(_isar, _selectedPatient!.id).then((_) {
            _selectedPatient = null;
            notifyListeners();
          });
        });
      }
    }
  }

  Exam newExam(List<Exam> exams) {
    int maxExamNumber = 0;

    for (Exam exam in exams) {
      String examName = exam.name;

      List<String> examNameParts = examName.split(' ');
      if (examNameParts.length == 2 && examNameParts[0] == 'Exame') {
        try {
          int examNumber = int.parse(examNameParts[1]);

          if (examNumber > maxExamNumber) {
            maxExamNumber = examNumber;
          }
        } catch (e) {
          // If the parsing fails, it means that the part following 'Exame' is not a number
          // So, we ignore this exam name
        }
      }
    }

    Exam newExam = Exam(
      selectedPatient!.id,
      'Exame ${maxExamNumber + 1}',
      DateTime.now(),
    );

    return newExam;
  }

  void selectPatient(Patient patient) async {
    _selectedPatient = patient;
    await getAllExamsByPatientId(patient.id).then((exams) async {
      _patientExams = exams;
      Exam exam = newExam(_patientExams);
      _currentExam = exam;
      await getAllSamplesByExamId(_currentExam!.id).then(
        (samples) {
          _examSamples = samples;
          notifyListeners();
        },
      );
    });
  }

  void clearSelectedPatient() {
    _selectedPatient = null;
    _currentExam = null;
    _patientExams = [];
    notifyListeners();
  }

  void checkForSelectedPatient(BuildContext context) {
    if (_selectedPatient == null && !_showingDialog) {
      _showingDialog = true;
      _showPatientSelectionModal(context);
    }
  }

  void _showPatientSelectionModal(BuildContext context) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const SelectPatient(),
        fullscreenDialog: true,
      ),
    )
        .then((_) {
      _showingDialog = false;
      if (selectedPatient == null) {
        checkForSelectedPatient(context);
      }
    });
  }

  Future<void> init() async {
    _isar = await _db.openIsar();
    notifyListeners();
  }

  Future<bool?> showDeletionConfirmationDialog(
      BuildContext context, String itemName, String itemType) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Excluir $itemType',
            style: textTheme.titleLarge,
          ),
          content: Text(
            'Você tem certeza de que deseja excluir $itemName?',
            style: textTheme.titleMedium,
          ),
          actions: [
            TextButton(
              child: Text(
                'Não',
                style: textTheme.bodyLarge,
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                'Sim',
                style: textTheme.bodyLarge,
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<List<Exam>> getAllExamsByPatientId(Id id) async {
    return await _db.getAllExamsByPatientId(_isar, id);
  }

  Future<void> saveExam() async {
    await _db.putExam(_isar, _currentExam!).then((_) async {
      await getAllExamsByPatientId(_selectedPatient!.id).then((exams) {
        _patientExams = exams;
        notifyListeners();
      });
    });
  }

  Future<void> createExam() async {
    await getAllExamsByPatientId(_selectedPatient!.id).then((exams) async {
      _patientExams = exams;
      Exam exam = newExam(_patientExams);
      _currentExam = exam;
      await getAllSamplesByExamId(_currentExam!.id).then((samples) async {
        _examSamples = samples;
        notifyListeners();
      });
    });
  }

  Future<void> setCurrentExam(Exam exam) async {
    _currentExam = exam;
    graphData = [];
    await getAllSamplesByExamId(_currentExam!.id).then((samples) async {
      _examSamples = samples;
      notifyListeners();
    });
  }

  Future<void> setCurrentSample(
      Sample sample, UsbConnectionProvider usbConnectionProvider) async {
    graphData = [];
    notifyListeners();
    _currentSample = sample;
    if (sample.filePath.isNotEmpty) {
      usbConnectionProvider.loadCSVData(sample.filePath).then((newGraphData) {
        graphData = newGraphData;
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  Future<void> deleteExam(BuildContext context) async {
    if (_currentExam != null) {
      bool? shouldDelete = await showDeletionConfirmationDialog(
          context, _currentExam!.name, 'Exame');
      if (shouldDelete!) {
        await getAllSamplesByExamId(_currentExam!.id).then((samples) async {
          for (var sample in samples) {
            await _db.deleteSample(_isar, sample.id);
          }
        }).then((_) async {
          await _db.deleteExam(_isar, _currentExam!.id).then((deleted) async {
            if (deleted) {
              _currentExam = null;
              await getAllExamsByPatientId(_selectedPatient!.id)
                  .then((exams) async {
                _patientExams = exams;
                _currentExam = _patientExams.last;
                await getAllSamplesByExamId(_currentExam!.id).then(
                  (samples) {
                    _examSamples = samples;
                    notifyListeners();
                  },
                );
              });
            }
          });
        });
      }
    }
  }

  void showRenameExamDialog(BuildContext context) async {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);
    final TextEditingController examNameController = TextEditingController();
    if (currentExam != null) {
      examNameController.text = _currentExam!.name;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Renomear Exame',
            style: textTheme.titleLarge,
          ),
          content: TextField(
            controller: examNameController,
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancelar',
                style: textTheme.bodyLarge,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Renomear',
                style: textTheme.bodyLarge,
              ),
              onPressed: () async {
                if (examNameController.text.isNotEmpty &&
                    _currentExam != null) {
                  _currentExam!.name = examNameController.text;
                  await _db.putExam(_isar, _currentExam!).then((_) {
                    notifyListeners();
                    Navigator.of(context).pop();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Sample newSample(List<Sample> samples, String sampleName, String filePath) {
    int maxSampleNumber = getMaxSampleNumber(samples);

    Sample newSample = Sample(
        _currentExam!.id,
        sampleName.isEmpty ? 'Amostra ${maxSampleNumber + 1}' : sampleName,
        -1,
        filePath);

    return newSample;
  }

  int getMaxSampleNumber(List<Sample> samples) {
    int maxSampleNumber = 0;

    for (Sample sample in samples) {
      String sampleName = sample.name;

      List<String> sampleNameParts = sampleName.split(' ');
      if (sampleNameParts.length == 2 && sampleNameParts[0] == 'Amostra') {
        try {
          int sampleNumber = int.parse(sampleNameParts[1]);

          if (sampleNumber > maxSampleNumber) {
            maxSampleNumber = sampleNumber;
          }
        } catch (e) {
          // If the parsing fails, it means that the part following 'Exame' is not a number
          // So, we ignore this exam name
        }
      }
    }
    return maxSampleNumber;
  }

  Future<List<Sample>> getAllSamplesByExamId(Id id) async {
    return await _db.getAllSamplesByExamId(_isar, id);
  }

  Future<void> createSample() async {
    await getAllSamplesByExamId(_currentExam!.id).then((samples) async {
      _examSamples = samples;
      graphData = [];
      if (_currentExam!.id <= 0) {
        await saveExam().then((_) async {
          Sample sample = newSample(_examSamples, '', '');
          await _db.putSample(_isar, sample).then((_) async {
            await getAllSamplesByExamId(_currentExam!.id).then((samples) async {
              _examSamples = samples;
              notifyListeners();
            });
          });
        });
      } else {
        Sample sample = newSample(_examSamples, '', '');
        await _db.putSample(_isar, sample).then((_) async {
          await getAllSamplesByExamId(_currentExam!.id).then((samples) async {
            _examSamples = samples;
            notifyListeners();
          });
        });
      }
    });
  }

  void deleteSample(Sample? sample, BuildContext context) async {
    if (_currentExam != null && sample != null) {
      bool? shouldDelete =
          await showDeletionConfirmationDialog(context, sample.name, 'Amostra');
      if (shouldDelete!) {
        await _db.deleteSample(_isar, sample.id).then((deleted) async {
          if (deleted) {
            await getAllSamplesByExamId(_currentExam!.id).then((samples) {
              _examSamples = samples;
              notifyListeners();
            });
          }
        });
      }
    }
  }

  void showRenameSampleDialog(BuildContext context, Sample? sample) async {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);
    final TextEditingController sampleNameController = TextEditingController();
    if (currentExam != null && sample != null) {
      sampleNameController.text = sample.name;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Renomear Amostra',
            style: textTheme.titleLarge,
          ),
          content: TextField(
            controller: sampleNameController,
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancelar',
                style: textTheme.bodyLarge,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Renomear',
                style: textTheme.bodyLarge,
              ),
              onPressed: () async {
                if (sampleNameController.text.isNotEmpty &&
                    _currentExam != null &&
                    sample != null) {
                  sample.name = sampleNameController.text;
                  await _db.putSample(_isar, sample).then((_) async {
                    await getAllSamplesByExamId(_currentExam!.id)
                        .then((samples) {
                      _examSamples = samples;
                      notifyListeners();
                      Navigator.of(context).pop();
                    });
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<PlatformFile> _pickFiles() async {
    return await FilePicker.platform
        .pickFiles(
      type: FileType.any,
      allowMultiple: false,

      allowedExtensions: ['svg'],
      dialogTitle: 'Importar Amostra',
      //initialDirectory: _initialDirectoryController.text,
      lockParentWindow: true,
    )
        .then((filePickerResult) {
      if (filePickerResult == null) {
        return PlatformFile(name: '', size: 0, path: '');
      }
      return filePickerResult.files.first;
    });
  }

  void importSample(BuildContext context) async {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    final TextEditingController sampleNameController = TextEditingController();

    String filePath = '';

    fileNameNotifier.value = '';

    if (currentExam != null) {
      await getAllSamplesByExamId(_currentExam!.id).then((samples) async {
        sampleNameController.text =
            'Amostra ${getMaxSampleNumber(samples) + 1}';

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Importar Amostra',
                style: textTheme.titleLarge,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: sampleNameController,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      TextButton(
                        child: Text(
                          'Selecionar Arquivo',
                          style: textTheme.bodyLarge,
                        ),
                        onPressed: () => _pickFiles().then((platformFile) {
                          fileNameNotifier.value = platformFile.name;
                          filePath = platformFile.path!;
                        }),
                      ),
                      filePath.isEmpty
                          ? const SizedBox.shrink()
                          : const SizedBox(
                              height: 16,
                              width: 16,
                            ),
                      ValueListenableBuilder<String>(
                        valueListenable: fileNameNotifier,
                        builder: (context, fileName, _) {
                          return Text(
                            fileName,
                            style: textTheme.labelMedium,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Cancelar',
                    style: textTheme.bodyLarge,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(
                    'Importar',
                    style: textTheme.bodyLarge,
                  ),
                  onPressed: () async {
                    if (currentExam!.id < 0) {
                      Navigator.of(context).pop();

                      return showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'Exame não Selecionado',
                              style: textTheme.titleLarge,
                            ),
                            content: Text(
                              'Nenhum exame foi selecionado. Salve o exame atual ou selecione um exame para importar amostras.',
                              style: textTheme.titleMedium,
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  'Ok',
                                  style: textTheme.bodyLarge,
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    if (sampleNameController.text.isNotEmpty &&
                        _currentExam != null &&
                        filePath.isNotEmpty) {
                      Sample sample = newSample(
                          samples, sampleNameController.text, filePath);
                      sample.name = sampleNameController.text;

                      await _db.putSample(_isar, sample).then((sampleId) async {
                        final directory =
                            await getApplicationDocumentsDirectory();

                        final path = directory.path;
                        final newFilePath =
                            '$path/${sample.examId}_$sampleId.csv';
                        sample.filePath = newFilePath;

                        File file = File(filePath);
                        await file.copy(newFilePath);

                        await _db.putSample(_isar, sample).then((_) async {
                          await getAllSamplesByExamId(_currentExam!.id)
                              .then((samples) {
                            _examSamples = samples;
                            notifyListeners();
                            Navigator.of(context).pop();
                          });
                        });
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      });
    }
  }

  void showEditPatientDialog(BuildContext context) async {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);
    final TextEditingController patientIdentificationController =
        TextEditingController();
    final TextEditingController patientAgeController = TextEditingController();

    if (_selectedPatient != null &&
        _selectedPatient!.identification.isNotEmpty) {
      patientIdentificationController.text = _selectedPatient!.identification;
    }

    if (_selectedPatient != null &&
        _selectedPatient!.age.toString().isNotEmpty) {
      patientAgeController.text = _selectedPatient!.age.toString();
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Editar Paciente',
            style: textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: patientIdentificationController,
                style: textTheme.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'Identificador do Paciente',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                ),
              ),
              TextField(
                controller: patientAgeController,
                style: textTheme.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'Idade do Paciente',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancelar',
                style: textTheme.bodyLarge,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Renomear',
                style: textTheme.bodyLarge,
              ),
              onPressed: () async {
                if (patientIdentificationController.text.isNotEmpty &&
                    patientAgeController.text.isNotEmpty &&
                    _selectedPatient != null) {
                  _selectedPatient!.identification =
                      patientIdentificationController.text;
                  _selectedPatient!.age = int.parse(patientAgeController.text);
                  await _db
                      .putPatient(_isar, _selectedPatient!)
                      .then((id) async {
                    await getPatient(context, id).then(
                      (patient) {
                        selectPatient(patient);
                        notifyListeners();
                        Navigator.of(context).pop();
                      },
                    );
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> _saveFile() async {
    return FilePicker.platform
        .saveFile(
          type: FileType.any,
          allowedExtensions: [],
          dialogTitle: 'Exportar Pacientes',
          fileName: 'emg_app_pacientes',
          lockParentWindow: true,
        )
        .then((pathSelected) => pathSelected ?? '');
  }

  Future<void> exportCSVDataBaseFile(BuildContext context) async {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    dataBaseMessage.value = 'Aguarde...';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Exportar Pacientes',
            style: textTheme.titleLarge,
          ),
          content: ValueListenableBuilder<String>(
            valueListenable: dataBaseMessage,
            builder: (context, fileName, _) {
              return Text(
                fileName,
                style: textTheme.titleMedium,
              );
            },
          ),
        );
      },
    );

    await _saveFile().then(
      (pathToSaveFile) async {
        pathToSaveFile = '$pathToSaveFile.csv';
        print(pathToSaveFile.toString());
        if (pathToSaveFile.isEmpty || pathToSaveFile == 'null') {
          dataBaseMessage.value = 'Nenhum local selecionado.';
          return await Future.delayed(const Duration(seconds: 3))
              .then((value) => Navigator.of(context).pop());
        }

        dataBaseMessage.value = 'Gerando arquivo...';
        await _buildDatabaseCSVFile(pathToSaveFile).then((value) async {
          dataBaseMessage.value = 'Arquivo gerado com sucesso.';
          return await Future.delayed(const Duration(seconds: 3))
              .then((value) => Navigator.of(context).pop());
        });
      },
    );
  }

  Future<void> _buildDatabaseCSVFile(String filePath) async {
    final file = File(filePath);
    final sink = file.openWrite();

    String line =
        'Id Paciente,Identificador Paciente,Idade Paciente,Id Exame,Nome Exame,Data Exame,Id Amostra,Nome Amostra,Valor Amostra,Nome Arquivo Amostra,Valores Amostra';

    sink.writeln(line);

    final patients = await _db.getAllPatients(_isar);

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    for (final patient in patients) {
      final exams = await _db.getAllExamsByPatientId(_isar, patient.id);

      for (final exam in exams) {
        final samples = await _db.getAllSamplesByExamId(_isar, exam.id);

        //abre o arquivo csv e transforma ele em um array com ;

        for (final sample in samples) {
          final csvLine = [
            patient.id.toString(),
            patient.identification,
            patient.age.toString(),
            exam.id.toString(),
            exam.name,
            dateFormat.format(exam.date),
            sample.id.toString(),
            sample.name,
            sample.value.toString(),
            sample.filePath,
            await readCSVFile(sample.filePath)
          ].join(',');

          sink.writeln(csvLine);
        }
      }
    }

    sink.close();
    return;
  }

  Future<String> readCSVFile(String filePath) async {
    final file = File(filePath);

    if (!file.existsSync()) {
      throw Exception('O arquivo não existe: $filePath');
    }

    final lines = await file.readAsLines();
    final formattedLines =
        lines.map((line) => line.replaceAll('\n', '')).toList();
    final csvContent = formattedLines.join(';');

    return csvContent;
  }
}
