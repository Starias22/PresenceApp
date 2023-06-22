import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/backend/models/utils/presence.dart';
import 'package:presence_app/backend/models/report_model/presence_record.dart';
import 'package:presence_app/backend/models/report_model/presence_report.dart';
import 'package:presence_app/utils.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;



class Report  {


  late List<int> bytes=[];
  
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
    saveAndDownloadPDFOnWeb(filename);
  }
  else{
    saveAndOpen(filename);
  }

}
Future<void> createAndDownloadOrOpenPdf(PresenceReport presenceReport)  async {
   await createPdf(presenceReport);
   saveAndOpenOrDownloadPdf('report.pdf');

}

  void saveAndDownloadPDFOnWeb(String filename) {
    html.AnchorElement(
      href: 'data:application/octet-stream;base64,${base64.encode(bytes)}',
    )
      ..setAttribute('download', filename)
      ..click();
  }
Future<void> createPdf(PresenceReport presenceReport) async {
  //Creates a new PDF document
  PdfDocument document = PdfDocument();

//Adds page settings
  document.pageSettings.orientation = PdfPageOrientation.landscape;
  document.pageSettings.margins.all = 50;

//Adds a page to the document
  PdfPage page = document.pages.add();
  PdfGraphics graphics = page.graphics;

//Loads the image from base64 string

  PdfImage image = PdfBitmap.fromBase64String(
      '/9j/4AAQSkZJRgABAQAAAQABAAD/4gIoSUNDX1BST0ZJTEUAAQEAAAIYAAAAAAQwAABtbnRyUkdCIFhZWiAAAAAAAAAAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlkZXNjAAAA8AAAAHRyWFlaAAABZAAAABRnWFlaAAABeAAAABRiWFlaAAABjAAAABRyVFJDAAABoAAAAChnVFJDAAABoAAAAChiVFJDAAABoAAAACh3dHB0AAAByAAAABRjcHJ0AAAB3AAAADxtbHVjAAAAAAAAAAEAAAAMZW5VUwAAAFgAAAAcAHMAUgBHAEIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFhZWiAAAAAAAABvogAAOPUAAAOQWFlaIAAAAAAAAGKZAAC3hQAAGNpYWVogAAAAAAAAJKAAAA+EAAC2z3BhcmEAAAAAAAQAAAACZmYAAPKnAAANWQAAE9AAAApbAAAAAAAAAABYWVogAAAAAAAA9tYAAQAAAADTLW1sdWMAAAAAAAAAAQAAAAxlblVTAAAAIAAAABwARwBvAG8AZwBsAGUAIABJAG4AYwAuACAAMgAwADEANv/bAEMA///////////////////////////////////////////////////////////////////////////////////////bAEMB///////////////////////////////////////////////////////////////////////////////////////AABEIASkDmQMBIgACEQEDEQH/xAAYAAEBAQEBAAAAAAAAAAAAAAAAAgEDBP/EACoQAQEAAgEEAwACAwACAwEAAAABAhExEiFBUWFxkTKBE6GxIuFCwdHw/8QAFgEBAQEAAAAAAAAAAAAAAAAAAAEC/8QAGhEBAQEBAQEBAAAAAAAAAAAAABEBQTEhUf/aAAwDAQACEQMRAD8A6AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA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');

//Draws the image to the PDF page
  page.graphics.drawImage(image, const Rect.fromLTWH(176, 0, 390, 130));


  PdfBrush solidBrush = PdfSolidBrush(PdfColor(126, 151, 173));
  Rect bounds = Rect.fromLTWH(0, 160, graphics.clientSize.width, 30);

//Draws a rectangle to place the heading in that region
  graphics.drawRectangle(brush: solidBrush, bounds: bounds);

//Creates a font for adding the heading in the page
  PdfFont subHeadingFont = PdfStandardFont(PdfFontFamily.timesRoman, 14);

//Creates a text element to add the invoice number
  PdfTextElement element =
  PdfTextElement(text: 'INVOICE 001', font: subHeadingFont);
  element.brush = PdfBrushes.white;

//Draws the heading on the page
  PdfLayoutResult result = element.draw(
      page: page, bounds: Rect.fromLTWH(10, bounds.top + 8, 0, 0))!;


  String currentDate = utils.formatDateTime(DateTime.now());

//Measures the width of the text to place it in the correct location
  Size textSize = subHeadingFont.measureString(currentDate);
  Offset textPosition = Offset(
      graphics.clientSize.width - textSize.width - 10, result.bounds.top);

//Draws the date by using drawString method
  graphics.drawString(currentDate, subHeadingFont,
      brush: element.brush,
      bounds: Offset(graphics.clientSize.width - textSize.width - 10,
          result.bounds.top) &
      Size(textSize.width + 2, 20));

//Creates text elements to add the address and draw it to the page
  element = PdfTextElement(
      text: 'BILL TO ',
      font: PdfStandardFont(PdfFontFamily.timesRoman, 10,
          style: PdfFontStyle.bold));
  element.brush = PdfSolidBrush(PdfColor(126, 155, 203));
  result = element.draw(
      page: page, bounds: Rect.fromLTWH(10, result.bounds.bottom + 25, 0, 0))!;

  PdfFont timesRoman = PdfStandardFont(PdfFontFamily.timesRoman, 10);

  element = PdfTextElement(text: 'Victuailles en stock ', font: timesRoman);
  element.brush = PdfBrushes.black;
  result = element.draw(
      page: page, bounds: Rect.fromLTWH(10, result.bounds.bottom + 10, 0, 0))!;

  element = PdfTextElement(
      text: '2, rue du Commerce, Lyon, France ', font: timesRoman);
  element.brush = PdfBrushes.black;
  result = element.draw(
      page: page, bounds: Rect.fromLTWH(10, result.bounds.bottom + 10, 0, 0))!;

//Draws a line at the bottom of the address
  graphics.drawLine(
      PdfPen(PdfColor(126, 151, 173), width: 0.7),
      Offset(0, result.bounds.bottom + 3),
      Offset(graphics.clientSize.width, result.bounds.bottom + 3));


  //Creates a PDF grid
  PdfGrid grid = PdfGrid();

//Add the columns to the grid
  grid.columns.add(count: 6);
  


//Add header to the grid
  grid.headers.add(1);

//Set values to the header cells
  PdfGridRow header = grid.headers[0];
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
  headerStyle.font = PdfStandardFont(PdfFontFamily.timesRoman, 14,
      style: PdfFontStyle.regular);

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

  var presences= await PresenceDB().getAllDailyPresenceRecords( DateTime(2023,6,6));


  List<PresenceRecord> presenceRows=[];
  PresenceRecord presenceRecord;
  Employee employee;


  for(var presence in presences){

    if(presence.status==EStatus.present||presence.status==EStatus.late) {
      employee=await EmployeeDB().getEmployeeById(presence.employeeId);
      presenceRecord=PresenceRecord(employee: employee, presence: presence);
      presenceRows.add(presenceRecord);
    }


  }

  var presenceReport=PresenceReport(presenceRows: presenceRows, date: '');

  PdfGridRow row;
  for(var presenceRow in presenceReport.presenceRows){
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

//Creates layout format settings to allow the table pagination
  PdfLayoutFormat layoutFormat =
  PdfLayoutFormat(layoutType: PdfLayoutType.paginate);

//Draws the grid to the PDF page
  PdfLayoutResult gridResult = grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, result.bounds.bottom + 20,
          graphics.clientSize.width, graphics.clientSize.height - 100),
      format: layoutFormat)!;

  gridResult.page.graphics.drawString(
      'Grand Total :                             \$386.91', subHeadingFont,
      brush: PdfSolidBrush(PdfColor(126, 155, 203)),
      bounds: Rect.fromLTWH(520, gridResult.bounds.bottom + 30, 0, 0));

  gridResult.page.graphics.drawString(
      'Thank you for your business !', subHeadingFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(520, gridResult.bounds.bottom + 60, 0, 0));

  bytes=await document.save();

}



}
