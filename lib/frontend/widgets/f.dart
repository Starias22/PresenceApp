import 'package:flutter/material.dart';

class ArrowAnimation extends StatefulWidget {
  final double size;

  const ArrowAnimation({Key? key, this.size = 48.0}) : super(key: key);

  @override
  _ArrowAnimationState createState() => _ArrowAnimationState();
}

class _ArrowAnimationState extends State<ArrowAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _offsetAnimation = Tween<Offset>(begin: Offset(-0.5, 0), end: Offset(0.5, 0))
        .chain(Tween<Offset>(begin: Offset(0.5, 0), end: Offset(-0.5, 0)) as Animatable<double>)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ))..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: ArrowPainter(Colors.red, 10),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  ArrowPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..close();

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

/*
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class StatistiquesCard extends StatelessWidget {
  StatistiquesCard({Key? key}) : super(key: key);
  final List data = ["service 1", "service 2", "service 3", "service 4", "service 5"];

  final List<charts.Series> data = [
    new charts.Series(
      id: 'Services',
      domainFn: (Service service, _) => service.serviceName,
      measureFn: (Service service, _) => service.servicePercentage,
      data: [
        new Service('Service 1', 20),
        new Service('Service 2', 15),
        new Service('Service 3', 25),
        new Service('Service 4', 10),
        new Service('Service 5', 30),
      ],
      labelAccessorFn: (Service service, _) => '${service.serviceName}: ${service.servicePercentage}%',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Diagramme en pourcentage'),
      ),
      body: new Center(
        child: new charts.PieChart(
          data,
          animate: true,
          animationDuration: Duration(milliseconds: 500),
          defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 60,
            arcRendererDecorators: [
              new charts.ArcLabelDecorator(
                labelPosition: charts.ArcLabelPosition.auto,
                showLeaderLines: false,
                labelPadding: 5,
                outsideLabelStyleSpec: new charts.TextStyleSpec(
                  fontSize: 12,
                  color: charts.Color.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/

/*
Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownSearch<MultiLevelString>(
                  key: myKey,
                  items: myItems,
                  compareFn: (i1, i2) => i1.level == i2.level,
                  popupProps: PopupProps.menu(
                    showSelectedItems: true,
                    interceptCallBacks: true,
                    itemBuilder: (ctx, item, isSelected) {
                      return ListTile(
                        selected: isSelected,
                        title: Text(item.level),
                        trailing: item.subLevel.isEmpty
                            ? null
                            : (item.isExpanded
                            ? IconButton(
                          icon: Icon(Icons.arrow_drop_down),
                          onPressed: () {
                            item.isExpanded = !item.isExpanded;
                            myKey.currentState?.updatePopupState();
                          },
                        )
                            : IconButton(
                          icon: Icon(Icons.arrow_right),
                          onPressed: () {
                            item.isExpanded = !item.isExpanded;
                            myKey.currentState?.updatePopupState();
                          },
                        )),
                        subtitle: item.subLevel.isNotEmpty && item.isExpanded
                            ? Container(
                          height: item.subLevel.length * 50,
                          child: ListView(
                            children: item.subLevel
                                .map(
                                  (e) => ListTile(
                                selected: myKey.currentState?.getSelectedItem
                                    ?.level ==
                                    e.level,
                                title: Text(e.level),
                                onTap: () {
                                  myKey.currentState?.popupValidate([e]);
                                },
                              ),
                            )
                                .toList(),
                          ),
                        )
                            : null,
                        onTap: () => myKey.currentState?.popupValidate([item]),
                      );
                    },
                  ),
                ),
              ),
*/