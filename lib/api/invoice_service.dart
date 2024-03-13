import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_document/open_document.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart%20';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';

class CustomRow {
  final String itemName;
  final String itemPrice;
  final String amount;
  final String total;
  final String vat;

  CustomRow(this.itemName, this.itemPrice, this.amount, this.total, this.vat);
}

class PdfInvoiceService {
  Future<Uint8List> createHelloWorld() {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("Hello World"),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> createInvoice(StudentPOS studentPOS) async {
    final pdf = pw.Document();

    final image = (await rootBundle.load("assets/images/dlsuccsLogo.png"))
        .buffer
        .asUint8List();

    final degree = studentPOS.degree == 'MIT'
        ? 'Master in Information Technology'
        : 'Master of Science in Information Technology';

    final finale = studentPOS.degree == 'MIT'
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
              pw.SizedBox(height: 25),
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.start, // Corrected alignment
                children: [
                  pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start, // Align children left
                    children: [
                      pw.Text(
                        "ID Number: ",
                        style: pw.TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "Student Name: ",
                        style: pw.TextStyle(fontWeight: FontWeight.bold),
                      ),
                      pw.Text(
                        "Student email: ",
                        style: pw.TextStyle(fontWeight: FontWeight.bold),
                      ),
                      pw.Text(
                        "Degree: ",
                        style: pw.TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start, // Align children left
                    children: [
                      pw.Text(studentPOS.idnumber.toString()),
                      pw.Text(
                        "${studentPOS.displayname['lastname']}, ${studentPOS.displayname['firstname']}",
                      ),
                      pw.Text(studentPOS.email),
                      pw.Text(studentPOS.degree),
                    ],
                  )
                ],
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

    if (studentPOS.degree == 'MIT') {
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
                            'DIT Student Name and Signature\nID#:\nDate:',
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
      List<Course> recommendedPriorityCourses) async {
    final pdf = pw.Document();

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
                              "${studentPOS.displayname['lastname']}, ${studentPOS.displayname['firstname']}",
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.center, // Center the text
                            ),
                            pw.Text(
                              "Name of Applicant (Last Name, First Name)",
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
                                  border: pw.Border.all(color: PdfColors.black),
                                ),
                              ),
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
                                  border: pw.Border.all(color: PdfColors.black),
                                ),
                              ),
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
                              "1.2. ENG501M/ENGF01M",
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  decoration: TextDecoration.underline),
                            ),
                            pw.Text(
                              "1.3. ${recommendedRemedialCourses[0].coursecode}: ${recommendedRemedialCourses[0].coursename}",
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
                                "1.${i + 1}. ${recommendedRemedialCourses[i].coursecode}: ${recommendedRemedialCourses[i].coursename}",
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
