import 'package:flutter/material.dart';

class ArrowAnimation extends StatefulWidget {
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
    _offsetAnimation = Tween<Offset>(begin: Offset(-0.5, 0), end: Offset(0.5, 0)).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
        reverseCurve: Curves.linear
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
      child: Icon(Icons.arrow_right_alt,
      size: 200,),
    );
  }
}
