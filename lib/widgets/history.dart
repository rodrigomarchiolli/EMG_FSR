import 'package:emg_app/models/exam.dart';
import 'package:emg_app/services/patient_provider.dart';
import 'package:emg_app/widgets/history_card.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

class History extends StatefulWidget {
  final Id patientId;
  const History({
    super.key,
    required this.patientId,
  });

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    return SizedBox(
      width: MediaQuery.of(context).size.width / 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 24, 12, 24),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Histórico',
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              Consumer<PatientProvider>(
                builder: (context, patientProvider, child) {
                  List<Exam> exams = patientProvider.patientExams;

                  if (exams.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Quando os exames forem salvos, eles irão aparecer aqui.',
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    return Column(
                      children: exams.map((exam) {
                        return GestureDetector(
                            onTap: () {
                              Provider.of<PatientProvider>(context,
                                      listen: false)
                                  .setCurrentExam(exam);
                            },
                            child: HistoryCard(
                                id: exam.id, nome: exam.name, data: exam.date));
                      }).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
