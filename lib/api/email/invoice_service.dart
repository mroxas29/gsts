import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_document/open_document.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart%20';
import 'package:sysadmindb/app/models/AcademicCalendar.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/en-19.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';

class CustomRow {
  final String itemName;
  final String itemPrice;
  final String amount;
  final String total;
  final String vat;

  CustomRow(this.itemName, this.itemPrice, this.amount, this.total, this.vat);
}

class PdfInvoiceService {
  Future<Uint8List> createPanelChairReport(EN19Form en19) async {
    final pdf = pw.Document();

    final image = (await rootBundle.load("assets/images/DLSU-Registrar.png"))
        .buffer
        .asUint8List();

    for (int i = 0; i < 2; i++) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(children: [
                pw.SizedBox(
                  height: 50,
                  width: 125,
                  child: pw.Image(pw.MemoryImage(image)),
                ),
                pw.Spacer(),
                pw.Text(
                  'Form No. R-23',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                )
              ]),
              pw.Center(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'PANEL CHAIR REPORT',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black),
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(1),
                },
                children: [
                  // First row with combined cells
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.RichText(
                          text: pw.TextSpan(
                            text: 'DATE OF DEFENSE\n',
                            style: pw.TextStyle(
                              fontSize: 8,
                            ),
                            children: [
                              pw.TextSpan(
                                text: 'Sample Date',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.RichText(
                          text: pw.TextSpan(
                            text: 'AY/TERM\n',
                            style: pw.TextStyle(
                              fontSize: 8,
                            ),
                            children: [
                              pw.TextSpan(
                                text: 'Sample AY/TERM',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Section headers
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'SECTION A: PROGRAM INFORMATION',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'SECTION B: STUDENT INFORMATION',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Individual rows for program information and student information
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'College of Computer Studies',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.RichText(
                          text: pw.TextSpan(
                            text: 'LAST NAME\n',
                            style: pw.TextStyle(
                              fontSize: 8,
                            ),
                            children: [
                              pw.TextSpan(
                                text: 'Doe',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'Department',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.RichText(
                          text: pw.TextSpan(
                            text: 'FIRST NAME\n',
                            style: pw.TextStyle(
                              fontSize: 8,
                            ),
                            children: [
                              pw.TextSpan(
                                text: 'John',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'Major/Specialization',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.RichText(
                          text: pw.TextSpan(
                            text: 'ID NO.\n',
                            style: pw.TextStyle(
                              fontSize: 8,
                            ),
                            children: [
                              pw.TextSpan(
                                text: '1234567890',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Section C without a partner
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'SECTION C: SUBMISSION OF REVISIONS',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          '',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ),
                    ],
                  ),
                  // Panel Chair and Thesis Title aligned
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          'PANEL CHAIR\n\nI certify that I have read the revised thesis/dissertation manuscript presented by the student as required by the members of the defense panel. I further certify that the revisions are in accordance with their instructions. As such, the student may now be deemed to have passed the defense.\n\nSIGNATURE OVER PRINTED NAME/DATE',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.RichText(
                          text: pw.TextSpan(
                            text: 'THESIS / DISSERTATION TITLE\n',
                            style: pw.TextStyle(
                              fontSize: 8,
                            ),
                            children: [
                              pw.TextSpan(
                                text: 'Sample Thesis Title',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return pdf.save();
  }

  Future<Uint8List> createDefenseForm(
      EN19Form en19, String defenseType, Student student) async {
    final pdf = pw.Document();
    bool hasProposal = student.pastCourses.any((course) =>
        course.coursename.toLowerCase().toLowerCase().contains('proposal') &&
        course.grade >= 2.0 &&
        course.grade <= 4);

    bool enrolledTD = student.enrolledCourses
        .any((course) => course.coursename.toLowerCase().contains('writing'));
    final image = (await rootBundle.load("assets/images/DLSU-Registrar.png"))
        .buffer
        .asUint8List();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(children: [
              pw.SizedBox(
                  height: 50,
                  width: 125,
                  child: pw.Image(pw.MemoryImage(image))),
              pw.Spacer(),
              pw.Text('EN-18-202211',
                  style: pw.TextStyle(fontWeight: FontWeight.bold))
            ]),
            pw.Center(
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                  pw.SizedBox(height: 10),
                  pw.Text('APPLICATION FOR DEFENSE',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 17,
                      )),
                  pw.Text('(for GRADUATE STUDENTS only)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                ])),
            pw.SizedBox(height: 10),
            pw.Text('PLEASE PRINT',
                style: pw.TextStyle(fontWeight: FontWeight.bold)),
            pw.Container(
              width: double.infinity,
              height: 17,
              color: PdfColors.black,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.Text(
                    'PERSONAL INFORMATION',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'DATE OF DEFENSE',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Rows 1-5 for personal information
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text('LAST NAME    '),
                              pw.Expanded(
                                child: pw.Container(
                                    height: 20,
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child: pw.Text(
                                        student.displayname['lastname']!)),
                              ),
                            ],
                          ),
                        ),
                        // Add other rows for personal information here
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text('FIRST NAME   '),
                              pw.Expanded(
                                child: pw.Container(
                                    height: 20,
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child: pw.Text(
                                        student.displayname['firstname']!)),
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                            color: PdfColors.black,
                          ),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Text(
                                'ACADEMIC INFORMATION',
                                style: pw.TextStyle(
                                    color: PdfColors.white,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text('ID NUMBER    '),
                              pw.Expanded(
                                child: pw.Container(
                                    height: 20,
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child:
                                        pw.Text(student.idnumber.toString())),
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text('COLLEGE OF   '),
                              pw.Expanded(
                                child: pw.Container(
                                    height: 20,
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child: pw.Text(en19.college)),
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text('PROGRAM      '),
                              pw.Expanded(
                                child: pw.Container(
                                    height: 20,
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child: pw.Text(student.degree)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          // Rows for defense date
                          pw.Text(en19.defenseDate),
                          pw.Container(
                            width: double.infinity,
                            color: PdfColors.black,
                            child: pw.Center(
                              child: pw.Text(
                                'TYPE OF DEFENSE',
                                style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.SizedBox(width: 10),
                                pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.SizedBox(height: 10),
                                      pw.Row(
                                        children: [
                                          pw.Container(
                                              padding: pw.EdgeInsets.all(8),
                                              width: 10,
                                              height: 10,
                                              decoration: pw.BoxDecoration(
                                                border: pw.Border.all(
                                                    color: PdfColors.black),
                                              ),
                                              child: pw.Center(
                                                  child: pw.Text(
                                                      defenseType
                                                                  .toLowerCase()
                                                                  .contains(
                                                                      'proposal') &&
                                                              defenseType
                                                                  .toLowerCase()
                                                                  .contains(
                                                                      'defense') &&
                                                              !defenseType
                                                                  .toLowerCase()
                                                                  .contains(
                                                                      'without')
                                                          ? 'X'
                                                          : '',
                                                      style: pw.TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          color: PdfColors
                                                              .black)))),
                                          pw.SizedBox(width: 5),
                                          pw.Text('Proposal Defense',
                                              style: pw.TextStyle(
                                                  fontSize: 8,
                                                  color: PdfColors.black)),
                                        ],
                                      ),
                                      pw.SizedBox(height: 10),
                                      pw.Row(
                                        children: [
                                          pw.Container(
                                              padding: pw.EdgeInsets.all(8),
                                              width: 10,
                                              height: 10,
                                              decoration: pw.BoxDecoration(
                                                border: pw.Border.all(
                                                    color: PdfColors.black),
                                              ),
                                              child: pw.Center(
                                                  child: pw.Text(
                                                      defenseType
                                                              .toLowerCase()
                                                              .contains('final')
                                                          ? 'X'
                                                          : '',
                                                      style: pw.TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          color: PdfColors
                                                              .black)))),
                                          pw.SizedBox(width: 5),
                                          pw.Text('Final Defense',
                                              style: pw.TextStyle(
                                                  fontSize: 8,
                                                  color: PdfColors.black)),
                                        ],
                                      ),
                                      pw.SizedBox(height: 10),
                                    ]),
                                pw.SizedBox(width: 10),
                                pw.Row(
                                  children: [
                                    pw.Container(
                                        padding: pw.EdgeInsets.all(8),
                                        width: 10,
                                        height: 10,
                                        decoration: pw.BoxDecoration(
                                          border: pw.Border.all(
                                              color: PdfColors.black),
                                        ),
                                        child: pw.Center(
                                            child: pw.Text(
                                                defenseType
                                                        .toLowerCase()
                                                        .contains('without')
                                                    ? 'X'
                                                    : '',
                                                style: pw.TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: PdfColors.black)))),
                                    pw.SizedBox(width: 5),
                                    pw.Text('Defense without proposal',
                                        style: pw.TextStyle(
                                            fontSize: 8,
                                            color: PdfColors.black)),
                                  ],
                                ),
                              ]),

                          pw.Container(
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black),
                              color: PdfColors.black,
                            ),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'TITLE OF PAPER TO BE USED',
                                  style: pw.TextStyle(
                                      color: PdfColors.white,
                                      fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          pw.Container(
                              height: 50,
                              width: double.infinity,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.black),
                              ),
                              child: pw.Column(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.center,
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(
                                          8.0), // You can adjust the padding as needed
                                      child: pw.Text(
                                        en19.mainTitle,
                                        style: pw.TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ])),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              height: 35,
              color: PdfColors.black,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'EVALUATION OF RECORDS',
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11),
                        ),
                        pw.Text(
                          '(FOR OUR USE ONLY, DO NOT FILL)',
                          style: pw.TextStyle(
                              color: PdfColors.white, fontSize: 11),
                        ),
                      ]),
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'PANEL COMPOSITION',
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          '(Please indicate the name)',
                          style:
                              pw.TextStyle(color: PdfColors.white, fontSize: 8),
                        ),
                      ])
                ],
              ),
            ),
            pw.Container(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Rows 1-5 for personal information
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text('Enrolled in T/D\nWriting',
                                  style: pw.TextStyle(fontSize: 9)),
                              pw.Expanded(
                                child: pw.Container(
                                  decoration: pw.BoxDecoration(
                                    border:
                                        pw.Border.all(color: PdfColors.black),
                                  ),
                                  child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.start,
                                      children: [
                                        pw.SizedBox(width: 10),
                                        pw.Column(
                                            mainAxisAlignment:
                                                pw.MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.SizedBox(height: 10),
                                              pw.Row(
                                                children: [
                                                  pw.Container(
                                                      padding:
                                                          pw.EdgeInsets.all(8),
                                                      width: 10,
                                                      height: 10,
                                                      decoration:
                                                          pw.BoxDecoration(
                                                        border: pw.Border.all(
                                                            color: PdfColors
                                                                .black),
                                                      ),
                                                      child: pw.Center(
                                                          child: pw.Text(
                                                              enrolledTD
                                                                  ? 'X'
                                                                  : '',
                                                              style: pw.TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold,
                                                                  color: PdfColors
                                                                      .black)))),
                                                  pw.SizedBox(width: 5),
                                                  pw.Text('YES',
                                                      style: pw.TextStyle(
                                                          fontSize: 8,
                                                          color:
                                                              PdfColors.black)),
                                                ],
                                              ),
                                              pw.SizedBox(height: 10),
                                              pw.Row(
                                                children: [
                                                  pw.Container(
                                                      padding:
                                                          pw.EdgeInsets.all(8),
                                                      width: 10,
                                                      height: 10,
                                                      decoration:
                                                          pw.BoxDecoration(
                                                        border: pw.Border.all(
                                                            color: PdfColors
                                                                .black),
                                                      ),
                                                      child: pw.Center(
                                                          child: pw.Text(
                                                              !enrolledTD
                                                                  ? 'X'
                                                                  : '',
                                                              style: pw.TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold,
                                                                  color: PdfColors
                                                                      .black)))),
                                                  pw.SizedBox(width: 5),
                                                  pw.Text('NO',
                                                      style: pw.TextStyle(
                                                          fontSize: 8,
                                                          color:
                                                              PdfColors.black)),
                                                ],
                                              ),
                                              pw.SizedBox(height: 10),
                                            ]),
                                        pw.SizedBox(width: 10),
                                        pw.Row(
                                          children: [
                                            pw.Container(
                                                padding: pw.EdgeInsets.all(8),
                                                width: 10,
                                                height: 10,
                                                decoration: pw.BoxDecoration(
                                                  border: pw.Border.all(
                                                      color: PdfColors.black),
                                                ),
                                                child: pw.Center(
                                                    child: pw.Text('',
                                                        style: pw.TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold,
                                                            color: PdfColors
                                                                .black)))),
                                            pw.SizedBox(width: 5),
                                            pw.Text('N/A',
                                                style: pw.TextStyle(
                                                    fontSize: 8,
                                                    color: PdfColors.black)),
                                          ],
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text('Passed Proposal\nDefense',
                                  style: pw.TextStyle(fontSize: 9)),
                              pw.Expanded(
                                child: pw.Container(
                                  decoration: pw.BoxDecoration(
                                    border:
                                        pw.Border.all(color: PdfColors.black),
                                  ),
                                  child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.start,
                                      children: [
                                        pw.SizedBox(width: 10),
                                        pw.Column(
                                            mainAxisAlignment:
                                                pw.MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.SizedBox(height: 10),
                                              pw.Row(
                                                children: [
                                                  pw.Container(
                                                      padding:
                                                          pw.EdgeInsets.all(8),
                                                      width: 10,
                                                      height: 10,
                                                      decoration:
                                                          pw.BoxDecoration(
                                                        border: pw.Border.all(
                                                            color: PdfColors
                                                                .black),
                                                      ),
                                                      child: pw.Center(
                                                          child: pw.Text(
                                                              hasProposal
                                                                  ? 'X'
                                                                  : '',
                                                              style: pw.TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold,
                                                                  color: PdfColors
                                                                      .black)))),
                                                  pw.SizedBox(width: 5),
                                                  pw.Text('YES',
                                                      style: pw.TextStyle(
                                                          fontSize: 8,
                                                          color:
                                                              PdfColors.black)),
                                                ],
                                              ),
                                              pw.SizedBox(height: 10),
                                              pw.Row(
                                                children: [
                                                  pw.Container(
                                                      padding:
                                                          pw.EdgeInsets.all(8),
                                                      width: 10,
                                                      height: 10,
                                                      decoration:
                                                          pw.BoxDecoration(
                                                        border: pw.Border.all(
                                                            color: PdfColors
                                                                .black),
                                                      ),
                                                      child: pw.Center(
                                                          child: pw.Text(
                                                              !hasProposal
                                                                  ? 'X'
                                                                  : '',
                                                              style: pw.TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold,
                                                                  color: PdfColors
                                                                      .black)))),
                                                  pw.SizedBox(width: 5),
                                                  pw.Text('NO',
                                                      style: pw.TextStyle(
                                                          fontSize: 8,
                                                          color:
                                                              PdfColors.black)),
                                                ],
                                              ),
                                              pw.SizedBox(height: 10),
                                            ]),
                                        pw.SizedBox(width: 10),
                                        pw.Row(
                                          children: [
                                            pw.Container(
                                                padding: pw.EdgeInsets.all(8),
                                                width: 10,
                                                height: 10,
                                                decoration: pw.BoxDecoration(
                                                  border: pw.Border.all(
                                                      color: PdfColors.black),
                                                ),
                                                child: pw.Center(
                                                    child: pw.Text('',
                                                        style: pw.TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold,
                                                            color: PdfColors
                                                                .black)))),
                                            pw.SizedBox(width: 5),
                                            pw.Text('N/A',
                                                style: pw.TextStyle(
                                                    fontSize: 8,
                                                    color: PdfColors.black)),
                                          ],
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        ),

                        pw.Container(
                          width: double.infinity,
                          height: 35,
                          color: PdfColors.black,
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                            children: [
                              pw.Column(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.center,
                                  children: [
                                    pw.Text(
                                      'APPROVED FOR DEFENSE',
                                      style: pw.TextStyle(
                                          color: PdfColors.white,
                                          fontWeight: pw.FontWeight.bold),
                                    ),
                                    pw.Text(
                                      '(ACCOMPLISH IN SEQUENCE)',
                                      style: pw.TextStyle(
                                          color: PdfColors.white, fontSize: 8),
                                    ),
                                  ])
                            ],
                          ),
                        ),
                        pw.Container(
                            width: double.infinity,
                            height: 115,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black),
                            ),
                            child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(
                                        8.0), // You can adjust the padding as needed
                                    child: pw.Text(
                                      'ADVISER',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(
                                        8.0), // You can adjust the padding as needed
                                    child: pw.Text(
                                      'I certify that I have read the thesis/dissertation manuscript presented by the\nstudent in connection with this application for proposal/final defense and classify\nthe same as eligible for defense within the schedule/deadlines set by the\nUniversity.',
                                      style: pw.TextStyle(
                                        fontSize: 6,
                                      ),
                                    ),
                                  ),
                                  pw.Spacer(),
                                  pw.Center(
                                      child: pw.Column(children: [
                                    pw.Text(
                                        '${en19.adviserName}/${getCurrentDate()}',
                                        style: pw.TextStyle(fontSize: 10)),
                                    pw.Text(
                                        'SIGNATURE OVER PRINTED NAME / DATE',
                                        style: pw.TextStyle(fontSize: 7)),
                                  ]))
                                ])),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Rows 1-5 for personal information
                        pw.Container(
                            height: 50,
                            width: double.infinity,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black),
                            ),
                            child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(
                                        8.0), // You can adjust the padding as needed
                                    child: pw.Text(
                                      'CHAIR\n\n${en19.leadPanel}',
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ])),
                        for (int i = 0; i < 4; i++)
                          pw.Container(
                              height: 50,
                              width: double.infinity,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.black),
                              ),
                              child: pw.Column(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(
                                          8.0), // You can adjust the padding as needed
                                      child: pw.Text(
                                        'MEMBER\n\n${en19.panelMembers[i]}',
                                        style: pw.TextStyle(
                                          fontSize: 8,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
                height: 45,
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment
                      .start, // Ensure CHAIR is on the top left
                  children: [
                    pw.Text(
                      'CHAIR / GS PROGRAM COORDINATOR',
                      style: pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                    pw.SizedBox(height: 8), // Add spacing between the texts
                    pw.Center(
                      child: pw.Text(
                        'Ms.Lissa Magpantay  ${getCurrentDate()}',
                        style: pw.TextStyle(
                          fontSize: 10, // Make the name bigger
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 8), // Add spacing between the texts
                    pw.Center(
                      child: pw.Text(
                        'SIGNATURE OVER PRINTED NAME / DATE',
                        style: pw.TextStyle(
                          fontSize: 6, // Make the signature text smaller
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )),
            pw.Container(
              width: double.infinity,
              height: 20,
              color: PdfColors.black,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'STUDENT CONFORME',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Column(children: [
                pw.Container(
                  height: 50,
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Container(
                          height: 50,
                          width: double.infinity,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Column(children: [
                            pw.Text(
                                "1. I have understood the 'Instructions' AND 'Terms and Conditions' at the page 2 of this form and agree to the same.",
                                style: pw.TextStyle(fontSize: 8)),
                            pw.SizedBox(height: 10),
                            pw.Text(
                                '${en19.firstName} ${en19.lastName} ${getCurrentDate()}',
                                style: pw.TextStyle(
                                    decoration: pw.TextDecoration.underline)),
                            pw.Text('SIGNATURE OVER PRINTED NAME/DATE',
                                style: pw.TextStyle(fontSize: 8)),
                          ])),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(children: [
              pw.SizedBox(
                height: 50,
                width: 125,
              ),
              pw.Spacer(),
              pw.Text('EN-18-202211',
                  style: pw.TextStyle(fontWeight: FontWeight.bold))
            ]),
            pw.Container(
              width: double.infinity,
              height: 25,
              color: PdfColors.black,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'ALL RIGHTS RESERVED. Parts of this material may be reproduced provided (1) the material is not altered; (2) the use is non-commercial;\n(3) De La Salle University is acknowledged as source; and (4) DLSU is notified through academic.services@dlsu.edu.ph. ',
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 7),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              height: 25,
              color: PdfColors.black,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'INSTRUCTIONS TO THE STUDENT',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              height: 150,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black),
              ),
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(
                    8.0), // Adjust the padding as needed
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "1. This form must be accomplished and must be submitted to the Office of the University Registrar through a "
                      "google form when all necessary signatures/email endorsements have been completed. Application forms with "
                      "incomplete signatures/email endorsement will not be accepted for processing.",
                      style: pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "2. If eligible, an assessment of the relevant fees for the application will be available through MLS Print EAF four "
                      "working days after submission.",
                      style: pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "3. The assessment will be printed in the Enrollment Assessment Form (EAF) that the student must download "
                      "through their MLS Account. Pay the assessed amount through the official payment method released by the "
                      "Finance and Accounting Office (FAO) "
                      "http://www.dlsu.edu.ph/offices/accounting/payments/default.asp . Together with the proof of payment and EAF must be submitted to the "
                      "Academic Department for the schedule of the Defense.",
                      style: pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "4. Coordinate the schedule and venue of the defense with the secretary of the academic department. Student "
                      "must submit a copy of the EAF (reflecting the enrollment in defense), proof of payment, and email approval "
                      "from OUR.",
                      style: pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "5. In case of final defense, student must follow the process and procedure of submission of the approved "
                      "thesis/dissertation through the animorepository. The full procedure is found at this link.",
                      style: pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ),
            pw.Container(
              width: double.infinity,
              height: 25,
              color: PdfColors.black,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'TERMS AND CONDITIONS',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              height: 100,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black),
              ),
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(
                    8.0), // Adjust the padding as needed
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "1. To be able to enroll for thesis/dissertation proposal/final defense, the student must be enrolled in "
                      "thesis/dissertation writing course during the term.",
                      style: pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "2. The thesis/dissertation proposal defense may be enrolled up to the end of Week 9 of the term. The "
                      "thesis/dissertation final defense may be enrolled up to the end of Week 7 of the term.",
                      style: pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "3. The enrollment is deemed final once reflected in the Student's EAF and can no longer withdraw/drop the "
                      "application.",
                      style: pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "4. A defense resulting to revision requirements in the thesis/dissertation is classified as 'Incomplete'. To qualify "
                      "for completion, revisions must be approved and reported by the Chair of the Defense Panel to the Office of "
                      "the University Registrar within three (3) terms from term of enrollment in defense. After this period, the "
                      "'Incomplete' is automatically converted to 'Failed,' in which case the student has to restart the "
                      "thesis/dissertation cycle.",
                      style: pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> createEN19(EN19Form en19, String role) async {
    final pdf = pw.Document();
    bool isStudent = role.toLowerCase().contains('student');
    final image = (await rootBundle.load("assets/images/DLSU-Registrar.png"))
        .buffer
        .asUint8List();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(children: [
              pw.SizedBox(
                  height: 50,
                  width: 125,
                  child: pw.Image(pw.MemoryImage(image))),
              pw.Spacer(),
              pw.Text('EN-19-202101',
                  style: pw.TextStyle(fontWeight: FontWeight.bold))
            ]),
            pw.Center(
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                  pw.SizedBox(height: 10),
                  pw.Text('ENROLLMENT OF THESIS/DISSERTATION WRITING',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 17,
                          decoration: TextDecoration.underline)),
                  pw.Text('(for GRADUATE STUDENTS only)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                ])),
            pw.SizedBox(height: 10),
            pw.Text('PLEASE PRINT',
                style: pw.TextStyle(fontWeight: FontWeight.bold)),
            pw.Container(
              width: double.infinity,
              height: 17,
              color: PdfColors.black,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.Text(
                    'PERSONAL INFORMATION',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'PROPOSED TITLE',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Rows 1-5 for personal information
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text('LAST NAME    '),
                              pw.Expanded(
                                child: pw.Container(
                                    height: 20,
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child: pw.Text(en19.lastName)),
                              ),
                            ],
                          ),
                        ),
                        // Add other rows for personal information here
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text('FIRST NAME   '),
                              pw.Expanded(
                                child: pw.Container(
                                    height: 20,
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child: pw.Text(en19.firstName)),
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                            color: PdfColors.black,
                          ),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Text(
                                'ACADEMIC INFORMATION',
                                style: pw.TextStyle(
                                    color: PdfColors.white,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text('ID NUMBER    '),
                              pw.Expanded(
                                child: pw.Container(
                                    height: 20,
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child: pw.Text(en19.idNumber)),
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text('COLLEGE OF   '),
                              pw.Expanded(
                                child: pw.Container(
                                    height: 20,
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child: pw.Text(en19.college)),
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text('PROGRAM      '),
                              pw.Expanded(
                                child: pw.Container(
                                    height: 20,
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child: pw.Text(en19.program)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      height: 115,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Rows for proposed title
                          pw.SizedBox(width: 5),
                          pw.Row(
                            children: [
                              pw.Container(
                                  padding: pw.EdgeInsets.all(8),
                                  width: 10,
                                  height: 10,
                                  decoration: pw.BoxDecoration(
                                    border:
                                        pw.Border.all(color: PdfColors.black),
                                  ),
                                  child: pw.Center(
                                      child: pw.Text(
                                          en19.proposedTitle == 'Thesis'
                                              ? 'X'
                                              : '',
                                          style: pw.TextStyle(
                                              fontSize: 12,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.black)))),
                              pw.SizedBox(width: 5),
                              pw.Text('Thesis   '),
                            ],
                          ),
                          pw.SizedBox(height: 10),
                          pw.Row(
                            children: [
                              pw.Container(
                                  padding: pw.EdgeInsets.all(8),
                                  width: 10,
                                  height: 10,
                                  decoration: pw.BoxDecoration(
                                    border:
                                        pw.Border.all(color: PdfColors.black),
                                  ),
                                  child: pw.Center(
                                      child: pw.Text(
                                          en19.proposedTitle == 'Dissertation'
                                              ? 'X'
                                              : '',
                                          style: pw.TextStyle(
                                              fontSize: 12,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.black)))),
                              pw.SizedBox(width: 5),
                              pw.Text('Dissertation'),
                            ],
                          ),
                          // Add other rows for proposed title here
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              height: 17,
              color: PdfColors.black,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'EVALUATION OF RECORDS',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              height: 15,
              color: PdfColors.black,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    '(DO NOT FILL)',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Rows 1-5 for personal information
                        pw.Container(
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black),
                            ),
                            child: pw.Row(children: [
                              pw.Text('Passed Comprehensive Examinations'),
                            ])),
                        // Add other rows for personal information here
                        pw.Container(
                            height: 15,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black),
                            ),
                            child: pw.Row(children: [
                              pw.Text(
                                  'Submitted Certificate of Academic Completion',
                                  style: pw.TextStyle(fontSize: 10)),
                            ])),
                        pw.Container(
                            height: 30,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black),
                            ),
                            child: pw.Row(children: [
                              pw.Text('Evaluated by'),
                            ])),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(children: [
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black),
                        ),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            // Rows for proposed title
                            pw.SizedBox(width: 5),
                            pw.Row(
                              children: [
                                pw.Container(
                                    padding: pw.EdgeInsets.all(8),
                                    width: 10,
                                    height: 10,
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child: pw.Center(
                                        child: pw.Text(
                                            en19.passedComprehensiveExams ==
                                                    true
                                                ? 'X'
                                                : '',
                                            style: pw.TextStyle(
                                                fontSize: 12,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black)))),
                                pw.SizedBox(width: 5),
                                pw.Text('Yes'),
                              ],
                            ),
                            pw.SizedBox(width: 10),
                            pw.Row(
                              children: [
                                pw.Container(
                                    padding: pw.EdgeInsets.all(8),
                                    width: 10,
                                    height: 10,
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child: pw.Center(
                                        child: pw.Text(
                                            en19.passedComprehensiveExams ==
                                                    false
                                                ? isStudent
                                                    ? ' '
                                                    : 'X'
                                                : '',
                                            style: pw.TextStyle(
                                                fontSize: 12,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black)))),
                                pw.SizedBox(width: 5),
                                pw.Text('No'),
                              ],
                            ),
                            pw.SizedBox(width: 10),
                            pw.Row(
                              children: [
                                pw.Container(
                                  padding: pw.EdgeInsets.all(8),
                                  width: 10,
                                  height: 10,
                                  decoration: pw.BoxDecoration(
                                    border:
                                        pw.Border.all(color: PdfColors.black),
                                  ),
                                ),
                                pw.SizedBox(width: 5),
                                pw.Text('NA'),
                              ],
                            ),
                            // Add other rows for proposed title here
                          ],
                        ),
                      ),
                      pw.Container(
                        height: 15,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black),
                        ),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            // Rows for proposed title
                            pw.SizedBox(width: 5),
                            pw.Row(
                              children: [
                                pw.Container(
                                    padding: pw.EdgeInsets.all(8),
                                    width: 10,
                                    height: 10,
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child: pw.Center(
                                        child: pw.Text(
                                            en19.submittedCertificate == true
                                                ? 'X'
                                                : '',
                                            style: pw.TextStyle(
                                                fontSize: 12,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black)))),
                                pw.SizedBox(width: 5),
                                pw.Text('Yes'),
                              ],
                            ),
                            pw.SizedBox(width: 10),
                            pw.Row(
                              children: [
                                pw.Container(
                                    padding: pw.EdgeInsets.all(8),
                                    width: 10,
                                    height: 10,
                                    decoration: pw.BoxDecoration(
                                      border:
                                          pw.Border.all(color: PdfColors.black),
                                    ),
                                    child: pw.Center(
                                        child: pw.Text(
                                            en19.submittedCertificate == false
                                                ? isStudent
                                                    ? ' '
                                                    : 'X'
                                                : '',
                                            style: pw.TextStyle(
                                                fontSize: 12,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black)))),
                                pw.SizedBox(width: 5),
                                pw.Text('No'),
                              ],
                            ),
                            pw.SizedBox(width: 10),
                            pw.Row(
                              children: [
                                pw.Container(
                                  padding: pw.EdgeInsets.all(8),
                                  width: 10,
                                  height: 10,
                                  decoration: pw.BoxDecoration(
                                    border:
                                        pw.Border.all(color: PdfColors.black),
                                  ),
                                ),
                                pw.SizedBox(width: 5),
                                pw.Text('NA'),
                              ],
                            ),
                            // Add other rows for proposed title here
                          ],
                        ),
                      ),
                      pw.Container(
                        height: 30,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            // Rows for proposed title
                            pw.SizedBox(width: 5),
                            pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.SizedBox(width: 5),
                                pw.Text('Ms. Lissa Magpantay',
                                    style: pw.TextStyle(
                                        decoration:
                                            pw.TextDecoration.underline)),
                              ],
                            ),
                            pw.SizedBox(width: 10),
                            pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.SizedBox(width: 5),
                                pw.Text('Signature/Date',
                                    style: pw.TextStyle(fontSize: 8)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              height: 20,
              color: PdfColors.black,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'ENROLLMENT STAGE',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              height: 17,
              color: PdfColors.black,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.Text(
                    'THESIS WRITING',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'DISSERTATION WRITING',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Rows 1-5 for personal information
                        pw.Container(
                            height: 100,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black),
                            ),
                            child: pw.Column(children: [
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceEvenly,
                                  children: [
                                    pw.Column(children: [
                                      for (int i = 1; i <= 4; i++)
                                        pw.Row(
                                          children: [
                                            pw.Center(
                                              child: pw.Container(
                                                  padding: pw.EdgeInsets.all(8),
                                                  width: 10,
                                                  height: 10,
                                                  decoration: pw.BoxDecoration(
                                                    border: pw.Border.all(
                                                        color: PdfColors.black),
                                                  ),
                                                  child: pw.Text(
                                                      en19.enrollmentStage ==
                                                              'Thesis $i'
                                                          ? 'X'
                                                          : '',
                                                      style: pw.TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          color: PdfColors
                                                              .black))),
                                            ),
                                            pw.SizedBox(width: 5),
                                            pw.Text('Thesis $i'),
                                          ],
                                        ),
                                    ]),
                                    pw.Column(children: [
                                      for (int i = 5; i <= 9; i++)
                                        pw.Row(
                                          children: [
                                            pw.Center(
                                              child: pw.Container(
                                                  padding: pw.EdgeInsets.all(8),
                                                  width: 10,
                                                  height: 10,
                                                  decoration: pw.BoxDecoration(
                                                    border: pw.Border.all(
                                                        color: PdfColors.black),
                                                  ),
                                                  child: pw.Text(
                                                      en19.enrollmentStage ==
                                                              'Thesis $i'
                                                          ? 'X'
                                                          : '',
                                                      style: pw.TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          color: PdfColors
                                                              .black))),
                                            ),
                                            pw.SizedBox(width: 5),
                                            pw.Text('Thesis $i'),
                                          ],
                                        ),
                                    ])
                                  ])
                            ])),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Rows 1-5 for personal information
                        pw.Container(
                            height: 100,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black),
                            ),
                            child: pw.Column(children: [
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceEvenly,
                                  children: [
                                    pw.Column(children: [
                                      for (int i = 1; i <= 5; i++)
                                        pw.Row(
                                          children: [
                                            pw.Center(
                                              child: pw.Container(
                                                  padding: pw.EdgeInsets.all(8),
                                                  width: 10,
                                                  height: 10,
                                                  decoration: pw.BoxDecoration(
                                                    border: pw.Border.all(
                                                        color: PdfColors.black),
                                                  ),
                                                  child: pw.Text(
                                                      en19.enrollmentStage ==
                                                              'Dissertation $i'
                                                          ? 'X'
                                                          : '',
                                                      style: pw.TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          color: PdfColors
                                                              .black))),
                                            ),
                                            pw.SizedBox(width: 5),
                                            pw.Text('Dissertation $i',
                                                style:
                                                    pw.TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                    ]),
                                    pw.Column(children: [
                                      for (int i = 6; i <= 10; i++)
                                        pw.Row(
                                          children: [
                                            pw.Center(
                                              child: pw.Container(
                                                  padding: pw.EdgeInsets.all(8),
                                                  width: 10,
                                                  height: 10,
                                                  decoration: pw.BoxDecoration(
                                                    border: pw.Border.all(
                                                        color: PdfColors.black),
                                                  ),
                                                  child: pw.Text(
                                                      en19.enrollmentStage ==
                                                              'Dissertation $i'
                                                          ? 'X'
                                                          : '',
                                                      style: pw.TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          color: PdfColors
                                                              .black))),
                                            ),
                                            pw.SizedBox(width: 5),
                                            pw.Text('Dissertation $i',
                                                style:
                                                    pw.TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                    ]),
                                    pw.Column(children: [
                                      for (int i = 10; i <= 15; i++)
                                        pw.Row(
                                          children: [
                                            pw.Center(
                                              child: pw.Container(
                                                  padding: pw.EdgeInsets.all(8),
                                                  width: 10,
                                                  height: 10,
                                                  decoration: pw.BoxDecoration(
                                                    border: pw.Border.all(
                                                        color: PdfColors.black),
                                                  ),
                                                  child: pw.Text(
                                                      en19.enrollmentStage ==
                                                              'Dissertation $i'
                                                          ? 'X'
                                                          : '',
                                                      style: pw.TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          color: PdfColors
                                                              .black))),
                                            ),
                                            pw.SizedBox(width: 5),
                                            pw.Text('Dissertation $i',
                                                style:
                                                    pw.TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                    ])
                                  ])
                            ])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              height: 17,
              color: PdfColors.black,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'NAME OF THESIS/DISSERTATION ADVISER',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              height: 15,
              color: PdfColors.black,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    '(PLEASE PRINT)',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
                padding: pw.EdgeInsets.all(8),
                width: double.infinity,
                height: 20,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(en19.adviserName,
                          style: pw.TextStyle(fontWeight: FontWeight.bold))
                    ])),
            pw.Container(
              width: double.infinity,
              height: 15,
              color: PdfColors.black,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'APPROVED FOR ENROLLMENT',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Rows 1-5 for personal information
                        pw.Container(
                            height: 50,
                            width: double.infinity,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black),
                            ),
                            child: pw.Column(children: [
                              pw.Text('CHAIR /GS PROGRAM COORDINATOR',
                                  style: pw.TextStyle(fontSize: 8)),
                              pw.SizedBox(height: 10),
                              pw.Text('Ms. Lissa Magpantay',
                                  style: pw.TextStyle(
                                      decoration: pw.TextDecoration.underline)),
                              pw.Text('SIGNATURE OVER PRINTED NAME/DATE',
                                  style: pw.TextStyle(fontSize: 8)),
                            ])),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(children: [
                      pw.Container(
                        height: 50,
                        width: double.infinity,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Container(
                                height: 50,
                                width: double.infinity,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(color: PdfColors.black),
                                ),
                                child: pw.Column(children: [
                                  pw.Text('FACULTY ADVISER',
                                      style: pw.TextStyle(fontSize: 8)),
                                  pw.SizedBox(height: 10),
                                  pw.Text(en19.adviserName,
                                      style: pw.TextStyle(
                                          decoration:
                                              pw.TextDecoration.underline)),
                                  pw.Text('SIGNATURE OVER PRINTED NAME/DATE',
                                      style: pw.TextStyle(fontSize: 8)),
                                ])),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              height: 20,
              color: PdfColors.black,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'STUDENT CONFORME',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Column(children: [
                pw.Container(
                  height: 50,
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Container(
                          height: 50,
                          width: double.infinity,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Column(children: [
                            pw.Text(
                                "1. I have understood the 'Instructions' AND 'Terms and Conditions' at the back of this form and agree to the same.",
                                style: pw.TextStyle(fontSize: 8)),
                            pw.SizedBox(height: 10),
                            pw.Text(
                                '${en19.firstName} ${en19.lastName} ${getCurrentDate()}',
                                style: pw.TextStyle(
                                    decoration: pw.TextDecoration.underline)),
                            pw.Text('SIGNATURE OVER PRINTED NAME/DATE',
                                style: pw.TextStyle(fontSize: 8)),
                          ])),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(children: [
              pw.SizedBox(
                height: 50,
                width: 125,
              ),
              pw.Spacer(),
              pw.Text('EN-19-202101',
                  style: pw.TextStyle(fontWeight: FontWeight.bold))
            ]),
            pw.Container(
              width: double.infinity,
              height: 25,
              color: PdfColors.black,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'ALL RIGHTS RESERVED. Parts of this material may be reproduced provided (1) the material is not altered; (2) the use is non-commercial;\n(3) De La Salle University is acknowledged as source; and (4) DLSU is notified through academic.services@dlsu.edu.ph. ',
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 7),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              height: 25,
              color: PdfColors.black,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'INSTRUCTIONS TO THE STUDENT',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.Container(
                height: 100,
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Column(children: [
                  pw.Text(
                      "1. This form must be accomplished must submitted to the Office of the University Registrar through a google\nform when all (except Associate Registrar) necessary signatures have been completed. Application forms with\nincomplete signatures/email endorsement will not be accepted for processing",
                      style: pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 5),
                  pw.Text(
                      "2. If eligible, an assessment of the relevant fees for the application will be available through MLS Print EAF four\nworking days after submission.",
                      style: pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 5),
                  pw.Text(
                      "3. The assessment will be printed in the Enrollment Assessment Form (EAF) that the student must download\nthrough their MLS Account. Pay the assessed amount through the official payment method released by the\nFinance and Accounting Office (FAO).",
                      style: pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 5),
                ])),
            pw.Container(
              width: double.infinity,
              height: 25,
              color: PdfColors.black,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'TERMS AND CONDITIONS',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.Container(
                height: 100,
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Column(children: [
                  pw.Text(
                      "1. To be able to enroll for thesis/dissertation writing, the student must have completed all academic\nrequirements and have passed all applicable comprehensive examinations.",
                      style: pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 5),
                  pw.Text(
                      "2. Thesis/dissertation Writing may be enrolled up to the end of Week 2 of the term only. Complete and detailed\nschedules can be found at\nhttps://www.dlsu.edu.ph/wp-content/uploads/pdf/registrar/schedules/enroll_gs.pdf",
                      style: pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 5),
                  pw.Text(
                      "3. Other policies covering thesis/dissertation writing are covered in the Graduate Student Handbook:\nhttps://www.dlsu.edu.ph/wp-content/uploads/pdf/registrar/student-handbook.pdf",
                      style: pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 5),
                  pw.Text(
                      "4. The enrollment is deemed final once reflected in the Student's EAF and can no longer withdraw the\napplication.",
                      style: pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 5),
                ])),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  String capitalize(String input) {
    if (input.isEmpty) {
      return '';
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  String getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('MM/dd/yyyy');
    return formatter.format(now);
  }

  Future<Uint8List> createInvoice(StudentPOS studentPOS) async {
    final pdf = pw.Document();

    final image = (await rootBundle.load("assets/images/dlsuccsLogo.png"))
        .buffer
        .asUint8List();

    final degree = studentPOS.degree.contains('MIT')
        ? 'Master in Information Technology'
        : 'Master of Science in Information Technology';

    final finale = studentPOS.degree.contains('MIT')
        ? 'Capstone Project Proposal (3 units)\nCapstone Project Final (3 units)'
        : 'Methods of Research (3 units)\nThesis Proposal Defense (3 units)\nThesis Final Defense (3 units)';

    List<pw.Widget> RemcourseWidgets = [];
    List<pw.Widget> FocourseWidgets = [];
    List<pw.Widget> SpezCourseWidgets = [];
    List<pw.Widget> ElcourseWidgets = [];
    List<pw.Widget> CapcourseWidgets = [];

    int remUnits = 0;
    int foUnits = 0;
    int elUnits = 0;
    int capUnits = 0;
    int electiveCount = 0;

// Iterate through the list of courses
    for (var course in courses) {
      // Check if the course contains the student's degree
      if (course.program
              .toLowerCase()
              .contains(studentPOS.degree.toLowerCase()) &&
          course.type.toLowerCase().contains('remedial')) {
        remUnits += course.units;
        // If it contains the degree, add it as a Text widget
        RemcourseWidgets.add(
          pw.Text("${course.coursecode}: ${course.coursename}",
              textAlign: TextAlign.left),
        );
      }
    }

    for (var course in courses) {
      // Check if the course contains the student's degree
      if (course.program
              .toLowerCase()
              .contains(studentPOS.degree.toLowerCase()) &&
          course.type.toLowerCase().contains('specialized')) {
        remUnits += course.units;
        // If it contains the degree, add it as a Text widget
        SpezCourseWidgets.add(
          pw.Text("${course.coursecode}: ${course.coursename}",
              textAlign: TextAlign.left),
        );
      }
    }

    for (var course in courses) {
      // Check if the course contains the student's degree
      if (course.program
              .toLowerCase()
              .contains(studentPOS.degree.toLowerCase()) &&
          course.type.toLowerCase().contains('foundation')) {
        foUnits += course.units;
        // If it contains the degree, add it as a Text widget
        FocourseWidgets.add(
          pw.Text("${course.coursecode}: ${course.coursename}",
              textAlign: TextAlign.left),
        );
      }
    }

    for (var course in courses) {
      // Check if the course contains the student's degree
      if (course.program
              .toLowerCase()
              .contains(studentPOS.degree.toLowerCase()) &&
          course.type.toLowerCase().contains('elective')) {
        elUnits += course.units;
        // If it contains the degree, add it as a Text widget
        ElcourseWidgets.add(
          pw.Text("${course.coursecode}: ${course.coursename}",
              textAlign: TextAlign.left),
        );
      }
    }

    List<pw.Widget> widgets = [];
    final imgWidget = pw.Image(pw.MemoryImage(image));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                height: 100,
                width: 200,
                child: pw.Image(pw.MemoryImage(image)),
              ),
              pw.Text(
                degree,
                style: pw.TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              pw.Text(
                "PROGRAM OF STUDY",
                style: pw.TextStyle(fontSize: 18),
              ),
              pw.Text(
                "For students accepted on ${studentPOS.acceptanceTerm}",
                style: pw.TextStyle(fontSize: 18),
              ),
              pw.SizedBox(height: 50),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(1), // Adjust column width as needed
                  1: pw.FlexColumnWidth(2), // Adjust column width as needed
                },
                children: [
                  for (var year in studentPOS.schoolYears)
                    pw.TableRow(
                      children: [
                        pw.Container(
                          padding: pw.EdgeInsets.all(8),
                          alignment: pw.Alignment.center,
                          decoration:
                              pw.BoxDecoration(color: PdfColors.grey300),
                          child: pw.Text(
                            year.name, // School year as header
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            for (var term in year.terms)
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    "${term.name}",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ), // Term name
                                  for (var course in term.termcourses)
                                    pw.Text(
                                      course.type
                                              .toLowerCase()
                                              .contains('elective')
                                          ? "Elective ${electiveCount += 1}"
                                          : "${course.coursecode}: ${course.coursename}",
                                    ), // Term course
                                ],
                              ),
                          ],
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

    if (studentPOS.degree.contains('MIT')) {
      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                      "${studentPOS.degree} Program Curricular Requirements",
                      style: pw.TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  pw.SizedBox(height: 10),
                  pw.Text("Bridging/Remedial Courses",
                      textAlign: TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: RemcourseWidgets),
                  pw.SizedBox(height: 5),
                  pw.Text("Foundation Courses  ($foUnits units)",
                      textAlign: TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: FocourseWidgets),
                  pw.SizedBox(height: 5),
                  pw.Text("Elective Courses (15 units)",
                      textAlign: TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: ElcourseWidgets),
                  pw.SizedBox(height: 5),
                  pw.Text(finale,
                      textAlign: TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  pw.Text('TOTAL \t 36 units',
                      textAlign: TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  pw.Text('\n\n\nNote:',
                      textAlign: TextAlign.left,
                      style: pw.TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  pw.Text(
                    '1. Comprehensive exam must be taken and passed before capstone project final defense.',
                    textAlign: TextAlign.left,
                  ),
                  pw.Row(
                    children: [
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Prepared by:\n\n\n\n\n\n',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            'Ms. Lissa Magpantay\nDate:${getCurrentDate()}',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(
                              height: 10), // Adjust the spacing as needed
                          pw.Text(
                            'MIT/MSIT Coordinator, CCS',
                            textAlign: pw.TextAlign.left,
                          ),
                        ],
                      ),
                      pw.SizedBox(width: 20), // Adjust the width as needed
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Noted by:\n\n\n\n\n\n',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            'Dr. Ronald Pascual\nDate:',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(
                              height: 10), // Adjust the spacing as needed
                          pw.Text(
                            'Asst Dean for Research &\nAdvanced Studies, CCS',
                            textAlign: pw.TextAlign.left,
                          ),
                        ],
                      ),
                      pw.SizedBox(width: 20), // Adjust the width as needed
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Conforme:\n\n\n\n\n\n',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            '${capitalize(studentPOS.displayname['firstname']!)} ${capitalize(studentPOS.displayname['lastname']!)}\nID#: ${studentPOS.idnumber}\nDate:${getCurrentDate()}',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ]);
          }));
    } else {
      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                      "${studentPOS.degree} Program Curricular Requirements",
                      style: pw.TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  pw.SizedBox(height: 10),
                  pw.Text("Bridging/Remedial Courses",
                      textAlign: TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: RemcourseWidgets),
                  pw.SizedBox(height: 5),
                  pw.Text("Foundation Courses  (12 units)",
                      textAlign: TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: FocourseWidgets),
                  pw.Text("Specialized Courses  (6 units)",
                      textAlign: TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: SpezCourseWidgets),
                  pw.SizedBox(height: 5),
                  pw.Text("Elective Courses (9 units)",
                      textAlign: TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: ElcourseWidgets),
                  pw.SizedBox(height: 5),
                  pw.Text(finale,
                      textAlign: TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  pw.Text('TOTAL \t 36 units',
                      textAlign: TextAlign.left,
                      style: pw.TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  pw.Text('\n\n\nNote:',
                      textAlign: TextAlign.left,
                      style: pw.TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  pw.Text(
                    '1. One local or one international Scopus-indexed published and presented paper that may be related to thesis topic',
                    textAlign: TextAlign.left,
                  ),
                  pw.Text(
                    '2.  Comprehensive exam must be taken and passed before thesis writing and thesis proposal defense.',
                    textAlign: TextAlign.left,
                  ),
                  pw.Row(
                    children: [
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Prepared by:\n\n\n\n\n\n',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            'Ms. Lissa Magpantay\nDate:',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(
                              height: 10), // Adjust the spacing as needed
                          pw.Text(
                            'MIT/MSIT Coordinator, CCS',
                            textAlign: pw.TextAlign.left,
                          ),
                        ],
                      ),
                      pw.SizedBox(width: 20), // Adjust the width as needed
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Noted by:\n\n\n\n\n\n',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            'Dr. Marnel Peradilla\nDate:',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(
                              height: 10), // Adjust the spacing as needed
                          pw.Text(
                            'Asst Dean for Research &\nAdvanced Studies, CCS',
                            textAlign: pw.TextAlign.left,
                          ),
                        ],
                      ),
                      pw.SizedBox(width: 20), // Adjust the width as needed
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Conforme:\n\n\n\n\n\n',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            'MSIT Student Name and Signature\nID#:\nDate:',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ]);
          }));
    }

    return pdf.save();
  }

  Future<Uint8List> createRecommendationForm(
      StudentPOS studentPOS,
      List<Course> recommendedRemedialCourses,
      List<Course> recommendedPriorityCourses,
      bool isEng501MChecked) async {
    final pdf = pw.Document();

    int startCount = isEng501MChecked ? 2 : 3;

    final image = (await rootBundle.load("assets/images/dlsulogo.png"))
        .buffer
        .asUint8List();

    // Define custom page format for long bond paper (8.5 x 13 inches) with margins of 0.5 inches
    final PdfPageFormat longBondPaper = PdfPageFormat(
      8.5 * PdfPageFormat.inch -
          0.5 *
              PdfPageFormat.inch *
              2, // Subtract 0.5 inches from each side for left and right margins
      13 * PdfPageFormat.inch -
          0.5 *
              PdfPageFormat.inch *
              2, // Subtract 0.5 inches from each side for top and bottom margins
    );
    final double columnHeight = 200.0; // Adjust the height as needed

    pdf.addPage(
      pw.Page(
        pageFormat: longBondPaper,
        build: (pw.Context context) {
          final officeText = pw.Text("Office of Admissions\nand Scholarships",
              style: pw.TextStyle(
                fontSize: 16,
              ));

          // Rectangle and text on the top right corner
          final referenceNoText = pw.Text("Reference No: ________________");
          final idNumberText = pw.Text("ID Number: ${studentPOS.idnumber}");

          return pw.Container(
            margin: pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 50),
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        height: 100,
                        width: 200,
                        child: pw.Image(pw.MemoryImage(image)),
                      ),
                      pw.SizedBox(width: 10), // Add space between logo and text
                      officeText,
                      pw.Spacer(),
                      pw.Container(
                          width: 200,
                          height: 50,
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                  color: PdfColors.black, width: 1)),
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                referenceNoText,
                                idNumberText,
                              ]))
                    ]),
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(height: 15),
                    pw.Text(
                      "GRADUATE STUDIES ADMISSION\nDEPARTMENT RECOMMENDATION FORM (DeRF)",
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center, // Center the text
                    ),
                    pw.SizedBox(height: 15),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "DATE: ${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}",
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(
                                'TO: OFFICE OF ADMISSIONS AND SCHOLARSHIPS (OAS)'),
                            pw.Text(
                              "FROM:_______________",
                            ),
                            pw.Text(
                              "Chair/Graduate Program Coordinator",
                              textAlign: pw.TextAlign.center, // Center the text
                            ),
                            pw.Text(
                              "(Sign over Printed Name)",
                              textAlign: pw.TextAlign.center, // Center the text
                            ),
                            pw.SizedBox(height: 15),
                            pw.Text(
                              "${capitalize(studentPOS.displayname['lastname']!)}, ${capitalize(studentPOS.displayname['firstname']!)}",
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.center, // Center the text
                            ),
                          ],
                        ),
                        pw.SizedBox(width: 50), // Add space between the columns
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "___________________",
                            ),
                            pw.Text(
                              "Department Name",
                            ),
                            pw.SizedBox(height: 15),
                            pw.Text(
                              "___________________",
                            ),
                            pw.Text(
                              "Graduate Program Code\n(where applicant was accepted)",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Text('Please be informed that the applicant is:',
                    style: pw.TextStyle(fontSize: 8)),
                pw.Row(
                  children: [
                    // Left column
                    pw.Container(
                      width: PdfPageFormat.letter.width / 2 -
                          20, // Adjust width as needed
                      height: 75,
                      padding: pw.EdgeInsets.all(10), // Add padding for borders
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1), // Add border
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Container(
                                width: 10,
                                height: 10,
                                margin: pw.EdgeInsets.only(right: 5),
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(color: PdfColors.black),
                                ),
                              ),
                              pw.Text("Accepted",
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.Row(
                            children: [
                              pw.Container(
                                  width: 10,
                                  height: 10,
                                  margin: pw.EdgeInsets.only(right: 5),
                                  decoration: pw.BoxDecoration(
                                    border:
                                        pw.Border.all(color: PdfColors.black),
                                  ),
                                  child: pw.Center(
                                      child: pw.Text(
                                          isEng501MChecked ? ' ' : 'X',
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              color: PdfColors.black)))),
                              pw.Text("Exempted from course"),
                            ],
                          ),
                          pw.Row(
                            children: [
                              pw.Container(
                                  width: 10,
                                  height: 10,
                                  margin: pw.EdgeInsets.only(right: 5),
                                  decoration: pw.BoxDecoration(
                                    border:
                                        pw.Border.all(color: PdfColors.black),
                                  ),
                                  child: pw.Center(
                                      child: pw.Text(
                                          isEng501MChecked ? 'X' : ' ',
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              color: PdfColors.black)))),
                              pw.Text("NOT Exempted from course",
                                  style: pw.TextStyle(fontSize: 10)),
                            ],
                          ),
                          pw.SizedBox(
                              height:
                                  20), // Add space between checkboxes and signature line
                          pw.Container(
                              height: 1,
                              color: PdfColors.black), // Signature line
                          pw.Text("Signature",
                              style: pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    // Right column
                    pw.Container(
                      width: PdfPageFormat.letter.width / 2 -
                          20, // Adjust width as needed
                      height: 75,
                      padding: pw.EdgeInsets.all(10), // Add padding for borders
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1), // Add border
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Container(
                                width: 10,
                                height: 10,
                                margin: pw.EdgeInsets.only(right: 5),
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(color: PdfColors.black),
                                ),
                              ),
                              pw.Text("Not Accepted",
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  )),
                            ],
                          ),
                          pw.SizedBox(
                              height:
                                  20), // Add space between checkbox and signature line
                          pw.Container(
                              height: 1,
                              color: PdfColors.black), // Signature line
                          pw.Text("Signature",
                              style: pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header for the chair/program coordinator
                    pw.Text(
                      "FOR THE CHAIR/PROGRAM COORDINATOR - Kindly indicate the COURSE CODE of the course requirements. Please mark N/A on lines left blank. Errors must be countersigned using your full name.",
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    // Header for section 1
                    pw.SizedBox(height: 10),
                    pw.Text(
                      "1. The following NON-ACADEMIC (e.g., Orientation) and BRIDGING ACADEMIC/COURSES (includes ENG501m/ENGF01M) are required in order to proceed to the program proper. For students, see course description at http://www.dlsu.edu.ph/academics/graduate-studies/programs.asp",
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    // Lines 1.1 - 1.6 split into two columns
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left column for lines 1.1 - 1.3
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.SizedBox(height: 10),
                            pw.Text(
                              "1.1. SPS5000/Orientation",
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  decoration: TextDecoration.underline),
                            ),
                            pw.Text(
                              isEng501MChecked
                                  ? "1.$startCount. ENG501M/ENGF01M"
                                  : "1.$startCount. ${recommendedRemedialCourses[0].coursecode}: ${recommendedRemedialCourses[0].coursename}",
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                        // Right column for lines 1.4 - 1.6
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.SizedBox(height: 10),
                            for (var i = 1;
                                i < recommendedRemedialCourses.length;
                                i++)
                              pw.Text(
                                "1.${i + startCount}. ${recommendedRemedialCourses[i].coursecode}: ${recommendedRemedialCourses[i].coursename}",
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    decoration: TextDecoration.underline),
                              ),
                          ],
                        ),
                      ],
                    ),
                    // Header for section 2
                    pw.SizedBox(height: 10),
                    pw.Text(
                      "2. On the first term of enrollment, the student is advised to enroll in any of the following courses:",
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    // Lines 2.1 - 2.8 split into two columns
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left column for lines 2.1 - 2.4
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            for (var i = 0;
                                i < recommendedPriorityCourses.length;
                                i++)
                              pw.Text(
                                "2.${i + 1}. ${recommendedPriorityCourses[i].coursecode}: ${recommendedPriorityCourses[i].coursename}",
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    decoration: TextDecoration.underline),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  "CHAIR/PROGRAM COORDINATOR's REMARKS (IF ANY):",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "______________________________________________________________",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "______________________________________________________________",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "______________________________________________________________",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "NOTE TO DEPARTMENT:",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "1. Please make sure that any change (ie., course addition and/or deletion) to the list of courses above must be countersigned by the Chair or the Program Coordinator using his/her full name.",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "2. Please submit to OAS in three (3) copies.",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "NOTE TO STUDENT:",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "1. You may see the course description at http://www.dlsu.edu.ph/academics/graduate-studies/programs.asp",
                  style: pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  "2. In case of changes, please present the revised copy of the DeRF to OAS during the Special Adjustment Period.",
                  style: pw.TextStyle(fontSize: 8),
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

  pw.Expanded itemColumn(List<CustomRow> elements) {
    return pw.Expanded(
      child: pw.Column(
        children: [
          for (var element in elements)
            pw.Row(
              children: [
                pw.Expanded(
                    child: pw.Text(element.itemName,
                        textAlign: pw.TextAlign.left)),
                pw.Expanded(
                    child: pw.Text(element.itemPrice,
                        textAlign: pw.TextAlign.right)),
                pw.Expanded(
                    child:
                        pw.Text(element.amount, textAlign: pw.TextAlign.right)),
                pw.Expanded(
                    child:
                        pw.Text(element.total, textAlign: pw.TextAlign.right)),
                pw.Expanded(
                    child: pw.Text(element.vat, textAlign: pw.TextAlign.right)),
              ],
            )
        ],
      ),
    );
  }

  Future<void> savePdfFile(String fileName, Uint8List byteList) async {
    final blob = html.Blob([byteList]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName);
    html.document.body!.append(anchor);
    anchor.click();
    html.Url.revokeObjectUrl(url);
    anchor.remove();
  }
}
