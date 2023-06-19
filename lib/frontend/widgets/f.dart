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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _offsetAnimation = Tween<Offset>(begin: const Offset(-0.5, 0), end: const Offset(0.5, 0))
        .chain(Tween<Offset>(begin: const Offset(0.5, 0), end: const Offset(-0.5, 0)) as Animatable<double>)
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
