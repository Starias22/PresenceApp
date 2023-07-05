import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:presence_app/backend/firebase/firestore/statististics_data.dart';
import 'package:presence_app/frontend/screens/pdf.dart';
import 'package:presence_app/frontend/widgets/statistics_card.dart';
import 'package:presence_app/utils.dart';
import '../widgets/cardTabbar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


class EmployeeStatisticsPerRanges extends StatefulWidget {
  late String employeeId;
  EmployeeStatisticsPerRanges({
    Key? key,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<EmployeeStatisticsPerRanges> createState() =>
      _EmployeeStatisticsPerRangesState();
}

class _EmployeeStatisticsPerRangesState
    extends State<EmployeeStatisticsPerRanges> {
  final GlobalKey _globalKey = GlobalKey();
  bool dataLoading = true;
  int _selectedIndex = 0;
  List<String> tabBars = ['Entrées', 'Sorties'];
  List<List<StatisticsData>> chartData = [];
  List<StatisticsData> chartDataAff = [];

  void _etat(int index) async {
    chartDataAff = chartData[index];
  }

  @override
  void initState() {
    super.initState();

    data(widget.employeeId).then((x) {
      if (mounted) {
        setState(() {
          chartData = x;
          chartDataAff = chartData[0];
          dataLoading = false;
        });
      }
    });
  }

  // Future<void> _saveDiagramAsPdf(Uint8List bytes) async {
  //   final pdf = pw.Document();
  //   final imageProvider = pw.MemoryImage(bytes);
  //   final image = pw.Image(imageProvider);
  //   pdf.addPage(pw.Page(build: (pw.Context context) {
  //     return pw.Center(child: image);
  //   }));
  //
  //   final directory = await getExternalStorageDirectory();
  //   final file = File('${directory.path}/diagram.pdf');
  //   await file.writeAsBytes(await pdf.save());
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Diagram saved as PDF successfully')),
  //   );
  // }

  Future<void> _saveDiagramAsPdf(Uint8List bytes) async {
    final pdf = pw.Document();
    final imageProvider = pw.MemoryImage(bytes);
    final image = pw.Image(imageProvider);
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(child: image);
    }));
var data=await pdf.save();

   ReportPdf().saveAndOpenOrDownloadPdf('stat.pdf');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Diagram saved as PDF successfully')),
    );
  }

  //
  // Future<Uint8List> _captureImage() async {
  //   try {
  //     RenderRepaintBoundary boundary =
  //     _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //     var image = await boundary.toImage(pixelRatio: 5.0);
  //     ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
  //     return byteData!.buffer.asUint8List();
  //   } catch (e) {
  //     print('Error capturing image: $e');
  //     return Uint8List(0);
  //   }
  // }
  //
  // Future<void> _saveImage(Uint8List bytes) async {
  //   // Directory? directory = await getExternalStorageDirectory();
  //   // File file = File('${directory!.path}/diagram.png');
  //   // await file.writeAsBytes(bytes);
  //   log.d('Saving image to pdf');
  //   ReportPdf().saveImgToPdf(bytes);
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Image saved successfully')),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabBars.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: const Text(
            "Statistiques par intervalles",
          ),
          centerTitle: true,
          actions: [
            if (!dataLoading)
              IconButton(
                tooltip: 'Enregistrer comme PDF',
                icon: const Icon(Icons.download, color: Colors.black),
                onPressed: () async {
                  // Uint8List bytes = await _captureImage();
                  // await _saveImage(bytes);
                },
              ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: true,
              snap: true,
              pinned: true,
              backgroundColor: Colors.white,
              title: Container(
                height: 100.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: TabBar(
                  tabs: List.generate(tabBars.length, (index) {
                    if (_selectedIndex == index) {
                      return CustomTab(
                        text: tabBars[index],
                        isSelected: true,
                      );
                    } else {
                      return CustomTab(text: tabBars[index]);
                    }
                  }),
                  isScrollable: true,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                      _etat(_selectedIndex);
                    });
                  },
                  indicatorColor: Colors.blueGrey.shade50,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: RepaintBoundary(
                key: _globalKey,
                child: Column(
                  children: [
                    if (dataLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      StatisticsCard(entryOrExitData: chartDataAff),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
