import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:presence_app/backend/firebase/storage.dart';
import 'package:presence_app/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presence_app/backend/models/presence_report_model/presence_record.dart';
import 'package:presence_app/backend/models/presence_report_model/presence_report.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';






class ReportPdf  {

  late List<int> bytes=[];
  PdfDocument document = PdfDocument();
  late PdfGraphics graphics ;
  PdfGrid grid = PdfGrid();
  late PdfGridRow header ;

Future<void> saveAndOpen(String filename) async {
  //Get external storage directory
  final directory = await getApplicationSupportDirectory();

//Get directory path
  final path = directory.path;

//Create an empty file to write PDF data
  File file = File('$path/$filename');

//Write PDF data
  await file.writeAsBytes(bytes, flush: true);

//Open the PDF document in mobile
  OpenFile.open('$path/$filename');

}

void saveAndOpenOrDownloadPdf(String filename) async {
  if(kIsWeb ) {

    Uint8List uint8List = Uint8List.fromList(bytes);
    Storage.saveFile(filename, 'application/pdf', uint8List);

    String pdfUrl= await Storage.getDownloadURL(filename);

if (await canLaunch(pdfUrl)) {
  await launch(
    pdfUrl,
    // forceSafariVC: false,
    // forceWebView: false,
  );
}
    else {
      throw 'Could not launch the PDF';
    }

  }
  else{

     saveAndOpen(filename);
  }

}
Future<void> createAndDownloadOrOpenPdf(List<PresenceReport> presenceReportByDate,
    List<DateTime> targetDates)  async {
   await createPdf(presenceReportByDate,targetDates);
   saveAndOpenOrDownloadPdf('report.pdf');

}


  void createATable(
  MapEntry<String?,List<PresenceRecord>> table){

  }

  Future<void> initPdf(List<PresenceReport> presenceReportByDate) async {

    var presenceReport=presenceReportByDate[0];
    bool isPeriodic=presenceReport.reportPeriodType==ReportType.periodic;

    //Adds page settings
    document.pageSettings.orientation = PdfPageOrientation.landscape;
    document.pageSettings.margins.all = 50;

    //Adds a page to the document
    PdfPage page = document.pages.add();
    graphics = page.graphics;

    String url = await Storage.getDownloadURL('imsp.png');
    var response = await get(Uri.parse(url));
    var data = response.bodyBytes;

    //Create a bitmap object.
    PdfImage image = PdfBitmap(data);

    //Draws the image to the PDF page
    page.graphics.drawImage(image, const Rect.fromLTWH(0, 0, 100, 100));


// Définit la police et la taille pour les textes
    PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 17);

// Dessine le texte "Institut de Mathematiques et de Sciences Physiques" à droite du logo
    String texte1 = "Institut de Mathématiques et de Sciences Physiques";
    graphics.drawString(
        texte1,
        font,
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(200, 0, graphics.clientSize.width - 110, 50),
        format: PdfStringFormat(alignment: PdfTextAlignment.left)
    );

// Dessine le texte "Rapport de presence des employes" à droite du logo
    String texte2 = "Rapport de présence des employés";
    graphics.drawString(
        texte2,
        font,
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(250, 40, graphics.clientSize.width - 110, 50),
        format: PdfStringFormat(alignment: PdfTextAlignment.left)
    );

    double logoTableMargin = 30.0; // Ajustez la valeur selon vos besoins

    String rapportTypeText = "Type de Rapport: ${utils.y(presenceReport.reportPeriodType)}";
    graphics.drawString(
        rapportTypeText,
        font,
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(275, 50 + logoTableMargin + 10, graphics.clientSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.left)
    );


    String statusText = "Status: ${presenceReport.fStatus}";
    graphics.drawString(
        statusText,
        font,
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 100 + logoTableMargin + 10, graphics.clientSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.left)
    );

    // );

    String servicesText = "Service: ${presenceReport.services==null?'Tous':presenceReport.services?[0]}";
    graphics.drawString(
        servicesText,
        font,
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(500, 100 + logoTableMargin + 10, graphics.clientSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.left)
    );

    String startDateText = presenceReport.formattedStartDate;
    graphics.drawString(
        startDateText,
        font,
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 100 + logoTableMargin + 50, graphics.clientSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.left)
    );



    if(isPeriodic) {
      String endDateText =presenceReport.formattedEndDate;
      graphics.drawString(
          endDateText,
          font,
          brush: PdfSolidBrush(PdfColor(0, 0, 0)),
          bounds: Rect.fromLTWH(500, 100 + logoTableMargin + 50,
              graphics.clientSize.width, 20),
          format: PdfStringFormat(alignment: PdfTextAlignment.left)
      );
    }
    page = document.pages.add();
    graphics = page.graphics;
  }

  void initGrid(){
    grid.columns.add(count: 6);
//
//     //Add header to the grid
    grid.headers.add(1);
    header = grid.headers[0];
    header.cells[0].value = "Nom de l'employé";
    header.cells[1].value = "Heure d'entrée";
    header.cells[2].value = 'Heure de sortie';
    header.cells[3].value = 'Durée de travail';
    header.cells[4].value = 'Ecart de ponctualité';
    header.cells[5].value = 'Ecart de départ';
        //Creates the header style
    PdfGridCellStyle headerStyle = PdfGridCellStyle();
    headerStyle.borders.all = PdfPen(PdfColor(126, 151, 173));
    headerStyle.backgroundBrush = PdfSolidBrush(PdfColor(126, 151, 173));
    headerStyle.textBrush = PdfBrushes.white;
    headerStyle.font =
        PdfStandardFont(PdfFontFamily.timesRoman, 14, style: PdfFontStyle.regular);

    //Adds cell customizations
    for (int i = 0; i < header.cells.count; i++) {

      if (i == 0 || i == 1) {
        header.cells[i].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.left,
            lineAlignment: PdfVerticalAlignment.middle);
      } else {
        header.cells[i].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle);
      }
      header.cells[i].style = headerStyle;
    }

  }





  Future<void> createPdf(List<PresenceReport> presenceReportByDate,
      List<DateTime> targetDates) async
  {

    await initPdf(presenceReportByDate);


    initGrid();


//     PdfGridRow row;
//
//     for (var presenceRow in presenceReport.presenceRowsByService[null]!) {
//       row = grid.rows.add();
//       row.cells[0].value = presenceRow.employeeName;
//       row.cells[1].value = presenceRow.entryTime;
//       row.cells[2].value = presenceRow.exitTime;
//       row.cells[3].value = presenceRow.workDuration;
//       row.cells[4].value = presenceRow.punctualityDeviation;
//       row.cells[5].value = presenceRow.exitDeviation;
//     }
//
//     //Set padding for grid cells
//     grid.style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
//
//     //Creates the grid cell styles
//     PdfGridCellStyle cellStyle = PdfGridCellStyle();
//     cellStyle.borders.all = PdfPens.white;
//     cellStyle.borders.bottom = PdfPen(PdfColor(217, 217, 217), width: 0.70);
//     cellStyle.font = PdfStandardFont(PdfFontFamily.timesRoman, 12);
//     cellStyle.textBrush = PdfSolidBrush(PdfColor(131, 130, 136));
//
//     //Adds cell customizations
//     for (int i = 0; i < grid.rows.count; i++) {
//       PdfGridRow row = grid.rows[i];
//       for (int j = 0; j < row.cells.count; j++) {
//         row.cells[j].style = cellStyle;
//         if (j == 0 || j == 1) {
//           row.cells[j].stringFormat = PdfStringFormat(
//               alignment: PdfTextAlignment.left,
//               lineAlignment: PdfVerticalAlignment.middle);
//         } else {
//           row.cells[j].stringFormat = PdfStringFormat(
//               alignment: PdfTextAlignment.right,
//               lineAlignment: PdfVerticalAlignment.middle);
//         }
//       }
//     }
//
//     //Creates layout format settings to allow the table pagination
//     PdfLayoutFormat layoutFormat =
//     PdfLayoutFormat(layoutType: PdfLayoutType.paginate);
//
//
//
//
//     PdfLayoutResult? gridResult;
//     // Draws the grid to the PDF page
//      gridResult = grid.draw(
//       page: page,
//       bounds: Rect.fromLTWH(0, 250,
//           graphics.clientSize.width, graphics.clientSize.height - 50),
//       format: layoutFormat,
//     );
//
//     // Calculate the remaining space on the current page
//     double remainingSpace = page.size.height - gridResult!.bounds.bottom;
//
// // Check if there is enough space to display the text on the current page
//     //if (remainingSpace < 200) {
//       // Create a new page
//       page = document.pages.add();
//       graphics = page.graphics;
//     //}
//
// // Calculate the center position horizontally
//     double centerX = graphics.clientSize.width / 2;
//
// // Calculate the bottom position vertically
//     double bottomY = graphics.clientSize.height - 50;
//
// // Draw the text at the bottom center of the current or new page
//     graphics.drawString(
//       "Just a test",
//       font,
//       brush: PdfSolidBrush(PdfColor(0, 0, 0)),
//       bounds: const Rect.fromLTWH(
//         300, // Horizontal position (centered)
//         0, // Vertical position (at the bottom)
//         200, // Width of the rectangle
//         50, // Height of the rectangle
//       ),
//       format: PdfStringFormat(alignment: PdfTextAlignment.center),
//     );



    bytes = await document.save();
  }
}
