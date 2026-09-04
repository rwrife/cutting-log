import 'package:cutting_log/src/domain/journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_overview.dart';
import 'package:cutting_log/src/features/home/journal_home_page.dart';
import 'package:cutting_log/src/platform/local_notification_gateway.dart';
import 'package:flutter/material.dart';

final class CuttingLogApp extends StatelessWidget {
  const CuttingLogApp({
    required this.overview,
    this.dataRepository,
    this.notificationGateway = const DisabledLocalNotificationGateway(),
    super.key,
  });

  final JournalOverview overview;
  final JournalDataRepository? dataRepository;
  final LocalNotificationGateway notificationGateway;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cutting Log',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF386A20)),
        useMaterial3: true,
      ),
      home: JournalHomePage(
        overview: overview,
        dataRepository: dataRepository,
        notificationGateway: notificationGateway,
      ),
    );
  }
}
