import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:presence_app/backend/firebase/firestore/statististics_data.dart';
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
  late PdfPage page ;
  PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 17),
       font2 = PdfStandardFont(PdfFontFamily.helvetica, 15) ;

  late List<int> bytes=[];
  PdfDocument document = PdfDocument();
  late PdfGraphics graphics ;
  late PdfGrid grid;
  late PdfGridRow header ;
  PdfLayoutFormat layoutFormat =
  PdfLayoutFormat(layoutType: PdfLayoutType.paginate);

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

    log.d('Of course on web');

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
  void createATable(
      MapEntry<String?,List<PresenceRecord>> table){

  }

  Future<void> saveImgToPdf(Uint8List  data) async {
    PdfPage page ;

    PdfDocument document = PdfDocument();

    document.pageSettings.orientation = PdfPageOrientation.portrait;
    document.pageSettings.margins.all = 50;

    //Adds a page to the document
    page = document.pages.add();
    graphics = page.graphics;

    log.d('Going to draw image in PDF file');

    //Create a bitmap object.
    PdfImage image = PdfBitmap(data);

    //Draws the image to the PDF page
    page.graphics.drawImage(image,  const Rect.fromLTWH(0, 0,
        600,
        600));
    bytes = await document.save();
    saveAndOpenOrDownloadPdf('statistics.pdf');

  }

Future<void> createAndDownloadOrOpenPdf(List<PresenceReport> presenceReportByDate,
    List<DateTime> targetDates)  async {
   await createPdf(presenceReportByDate,targetDates);
   saveAndOpenOrDownloadPdf('report.pdf');

}



Future<void> setPdfHeader(bool portrait) async {
  //Adds page settings
  document.pageSettings.orientation =
  portrait? PdfPageOrientation.portrait: PdfPageOrientation.landscape;
  document.pageSettings.margins.all = 50;

  //Adds a page to the document
  page = document.pages.add();
  graphics = page.graphics;

  String url = await Storage.getDownloadURL('imsp.png');
  var response = await get(Uri.parse(url));
  var data = response.bodyBytes;

  //Create a bitmap object.
  PdfImage image = PdfBitmap(data);

  //Draws the image to the PDF page
  page.graphics.drawImage(image, const Rect.fromLTWH(0, 0, 100, 100));

  ByteData byteData = await
  rootBundle.load('assets/images/app1.png');

  data = byteData.buffer.asUint8List();
  image = PdfBitmap(data);
  page.graphics.drawImage(image, const Rect.fromLTWH(600, 0, 120, 100));


// Définit la police et la taille pour les textes


// Dessine le texte ite du logo
  String texte1 = "Institut de Mathématiques et de Sciences Physiques";
  graphics.drawString(
      texte1,
      font,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(200, 0, graphics.clientSize.width - 110, 50),
      format: PdfStringFormat(alignment: PdfTextAlignment.left)
  );
}



  Future<void> setPortraitPdfHeader() async {
    //Adds page settings
    document.pageSettings.orientation = PdfPageOrientation.portrait;
    document.pageSettings.margins.all = 20;

    //Adds a page to the document
    page = document.pages.add();
    graphics = page.graphics;

    String url = await Storage.getDownloadURL('imsp.png');
    var response = await get(Uri.parse(url));
    var data = response.bodyBytes;

    //Create a bitmap object.
    PdfImage image = PdfBitmap(data);

    //Draws the image to the PDF page
    page.graphics.drawImage(image, const Rect.fromLTWH(0, 0, 60, 60));

    ByteData byteData = await
    rootBundle.load('assets/images/app1.png');

    data = byteData.buffer.asUint8List();
    image = PdfBitmap(data);
    page.graphics.drawImage(image, const Rect.fromLTWH(500, 0, 60, 60));


// Définit la police et la taille pour les textes


// Dessine le texteSciences Physiques" à droite du logo
    String texte1 = "Institut de Mathématiques et de Sciences Physiques";
    graphics.drawString(
        texte1,
        font2,
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(100, 0, graphics.clientSize.width - 110, 50),
        format: PdfStringFormat(alignment: PdfTextAlignment.left)
    );
  }

void initGridForStatistics(){
  grid = PdfGrid();
  grid.columns.add(count: 2);
//
//     //Add header to the grid
  grid.headers.add(1);
  header = grid.headers[0];
  header.cells[0].value = "Intervalles";
  header.cells[1].value = "Pourcentages";
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

Future<void> statisticsPerRanges(String employeeName,
    List<List<StatisticsData>> chartData, String month) async {

  await setPortraitPdfHeader();
  // Dessine le texte "Rapport de presence des employes" à droite du logo
  String texte2 = "Statistiques de présence par intervalles";
  graphics.drawString(
      texte2,
      font2,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(150, 30, graphics.clientSize.width - 110, 50),
      format: PdfStringFormat(alignment: PdfTextAlignment.left)
  );

  String monthText = "Mois: $month";
  graphics.drawString(
      monthText,
      font2,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(200, 50, graphics.clientSize.width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left)
  );


  // Ajustez la valeur selon vos besoins

  String rapportTypeText = "Employé concerné: $employeeName";
  graphics.drawString(
      rapportTypeText,
      font2,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(100, 80, graphics.clientSize.width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left)
  );

  String entry = "Statistiques des entrées";
  graphics.drawString(
      entry,
      font2,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(200,110, graphics.clientSize.width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left)
  );
   initGridForStatistics();
  List<StatisticsData> entries=chartData[0],
  exits=chartData[1];

  PdfGridRow row;
  for (var data in entries){
    row=grid.rows.add();
    row.cells[0].value=data.timeRange;
    row.cells[1].value='${data.percentage}%';

  }
  grid.draw(page: page, bounds: const Rect.fromLTWH(100, 140, 0, 0));

  String exit = "Statistiques des sorties";
  graphics.drawString(
      exit,
      font2,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(200,230, graphics.clientSize.width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left)
  );
  initGridForStatistics();


  for (var data in exits){
    row=grid.rows.add();
    row.cells[0].value=data.timeRange;
    row.cells[1].value='${data.percentage}%';

  }
  grid.draw(page: page, bounds: const Rect.fromLTWH(100, 270, 0, 0));
  bytes = await document.save();
  saveAndOpenOrDownloadPdf('statis.pdf');




}

  Future<void> initPdf(List<PresenceReport> presenceReportByDate) async {

    await setPdfHeader(false);

    var presenceReport=presenceReportByDate[0];

    bool isPeriodic=presenceReport.reportPeriodType==ReportType.periodic;
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

    String servicesText = "Service:"
        " ${presenceReport.services==null?'Tous':presenceReport.services?[0]}";
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
    grid = PdfGrid();
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




    for(int i=0;i<targetDates.length;i++ ){
      initGrid();
      drawReportGridForADay(targetDates[i],presenceReportByDate[i]);
      // Add the following line to draw the grid on each page
      grid.draw(page: page, bounds: const Rect.fromLTWH(0, 50, 0, 0));
      if(i==targetDates.length-1) {
        break;
      }

      page = document.pages.add();
      graphics = page.graphics;

    }
    bytes = await document.save();
  }

  void drawReportGridForADay(DateTime date,PresenceReport presenceReport){

    graphics.drawString(
      '${utils.day(date)} ${utils.frenchFormatDate(date)}',
      font,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: const Rect.fromLTWH(
        300, // Horizontal position (centered)
        0, // Vertical position (at the bottom)
        200, // Width of the rectangle
        50, // Height of the rectangle
      ),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    PdfGridRow row;

    for (var presenceRow in presenceReport.presenceRowsByService[null]!) {
      row = grid.rows.add();
      row.cells[0].value = presenceRow.employeeName;
      row.cells[1].value = presenceRow.entryTime;
      row.cells[2].value = presenceRow.exitTime;
      row.cells[3].value = presenceRow.workDuration;
      row.cells[4].value = presenceRow.punctualityDeviation;
      row.cells[5].value = presenceRow.exitDeviation;
    }


    //Set padding for grid cells
    grid.style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);

    //Creates the grid cell styles
    PdfGridCellStyle cellStyle = PdfGridCellStyle();
    cellStyle.borders.all = PdfPens.white;
    cellStyle.borders.bottom = PdfPen(PdfColor(217, 217, 217), width: 0.70);
    cellStyle.font = PdfStandardFont(PdfFontFamily.timesRoman, 12);
    cellStyle.textBrush = PdfSolidBrush(PdfColor(131, 130, 136));

    //Adds cell customizations
    for (int i = 0; i < grid.rows.count; i++) {
      PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        row.cells[j].style = cellStyle;
        if (j == 0 || j == 1) {
          row.cells[j].stringFormat = PdfStringFormat(
              alignment: PdfTextAlignment.left,
              lineAlignment: PdfVerticalAlignment.middle);
        } else {
          row.cells[j].stringFormat = PdfStringFormat(
              alignment: PdfTextAlignment.right,
              lineAlignment: PdfVerticalAlignment.middle);
        }
      }
    }

    // Draws the grid to the PDF page



  }
}
