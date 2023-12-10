import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:scheduler_app/ChatRoom/home_screen.dart';
import 'package:scheduler_app/scheduler.dart';
import 'package:pdf/widgets.dart' as pw;

// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'dart:typed_data';

class ScheduleScreen extends StatelessWidget {
  final List<StaffMember> staffMembers;
  final Map<StaffMember, List<String>> schedules;

  ScheduleScreen({required this.staffMembers, required this.schedules});

  @override
  Widget build(BuildContext context) {
    // Flatten the map entries and sort them by date
    List<MapEntry<StaffMember, String>> sortedEntries = schedules.entries
        .expand((entry) => entry.value.map((date) => MapEntry(entry.key, date)))
        .toList()
      ..sort((a, b) {
        // Adjust the date format according to your input format
        DateTime aDate = _parseDate(a.value);
        DateTime bDate = _parseDate(b.value);
        return aDate.compareTo(bDate);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Schedule'),
        actions: [
          PopupMenuButton<String>(
            color: Colors.cyan,
            icon: const Icon(Icons.menu_open_sharp),
            iconSize: 30,
            onSelected: (value) async {
              if (value == 'share') {
                sendEmail();
              } else if (value == 'download') {
                await generateAndSavePDF(context, sortedEntries);
              } else if (value == 'chart') {
                // ignore: use_build_context_synchronously
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'share',
                child: Text('Share'),
              ),
              const PopupMenuItem<String>(
                value: 'download',
                child: Text('Download'),
              ),
              const PopupMenuItem<String>(
                value: 'chart',
                child: Text('Charts'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "STAFF WORKING TIMETABLE",
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              const SizedBox(
                height: 16,
              ),
              Table(
                border: TableBorder.all(),
                children: [
                  TableRow(
                    children: [
                      buildTableCell(
                        'Date',
                        const Color(0xFFCCE5FF),
                      ), // Add background color to Date column
                      buildTableCell(
                          'Staff Member',
                          const Color(
                              0xFFE6F9FF)), // Add background color to Staff Member column
                      buildTableCell(
                          'Work Schedule',
                          const Color(
                              0xFFFFD6D6)), // Add background color to Work Schedule column
                    ],
                  ),
                  ...sortedEntries.map((entry) {
                    StaffMember staff = entry.key;
                    String date = entry.value;

                    return TableRow(
                      children: [
                        buildTableCell(
                            date,
                            const Color(
                                0xFFCCE5FF)), // Add background color to Date column
                        buildTableCell(
                            staff.name,
                            const Color(
                                0xFFE6F9FF)), // Add background color to Staff Member column
                        buildTableCell(
                            'Work',
                            const Color(
                                0xFFFFD6D6)), // You can replace this with the actual work schedule for the date and add background color to Work Schedule column
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create TableCell with background color
  TableCell buildTableCell(String text, Color backgroundColor) {
    return TableCell(
      child: Container(
        color: backgroundColor,
        child: Center(child: Text(text)),
      ),
    );
  }

  void sendEmail() async {
    final smtpServer = gmail('tusiimealexkk@gmail.com', '123@alexkk');

    final message = Message()
      ..from = const Address('your.email@gmail.com', 'Your Name')
      ..recipients = ['manzialex1998@gmail.com']
      ..subject = "subject"
      ..text = "body";

    try {
      final sendReport = await send(message, smtpServer);
      if (kDebugMode) {
        print('Message sent: $sendReport');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> generateAndSavePDF(BuildContext context,
      List<MapEntry<StaffMember, String>> sortedEntries) async {
    final schedulepdf = pw.Document();

    // Add content to the PDF document
    schedulepdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'STAFF WORKING TIMETABLE',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontStyle: pw.FontStyle.italic,
                  fontSize: 20,
                  color: const PdfColor.fromInt(0x00FFFF), // Cyan color
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Container(
                        alignment: pw.Alignment.center,
                        child: pw.Text('Date',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.center,
                        child: pw.Text('Staff Member',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.center,
                        child: pw.Text('Work Schedule',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  for (var entry in sortedEntries)
                    pw.TableRow(
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.center,
                          color: const PdfColor.fromInt(0xFFFFD6D6),
                          // color: pw.Color.fromHex('#FFEB3B'), // Yellow color for Date column
                          child: pw.Text(entry.value),
                        ),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          color: const PdfColor.fromInt(
                              0xFFD4EDDA), // Lime color for Staff Member column
                          child: pw.Text(entry.key.name),
                        ),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          color: const PdfColor.fromInt(
                              0xFFFFF3CD), // Amber color for Work Schedule column
                          child: pw.Text(
                              'Work'), // You can replace this with the actual work schedule for the date
                        ),
                      ],
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF document
    try {
      // Save the PDF document
      Printing.layoutPdf(
        name: 'schedule.pdf',
        onLayout: (PdfPageFormat format) => schedulepdf.save(),
      );
    } catch (e) {
      // Handle the case where an error occurs during file saving

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save the PDF: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  DateTime _parseDate(String date) {
    // Adjust the parsing logic according to your input date format
    List<String> dateParts = date.split('/');
    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);
    return DateTime(year, month, day);
  }
}
