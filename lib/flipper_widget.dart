import 'dart:math';

import 'package:flutter/widgets.dart';

enum FlipDirection { right, left, up, down }

class FlipperWidget extends StatefulWidget {
  final Widget _front;
  final Widget _back;
  final FlipperWidgetController _controller;
  final Duration _duration;
  final Curve _curve;
  final FlipDirection _flipDirection;

  FlipperWidget(
      {required Widget front,
        required Widget back,
        required FlipperWidgetController controller,
        Duration duration = const Duration(milliseconds: 300),
        Curve curve = Curves.easeInExpo,
        FlipDirection flipDirection = FlipDirection.left})
      : _front = front,
        _back = back,
        _controller = controller,
        _duration = duration,
        _curve = curve,
        _flipDirection = flipDirection;

  @override
  State<StatefulWidget> createState() => FlipperWidgetState();
}

class FlipperWidgetState extends State<FlipperWidget>
    with TickerProviderStateMixin {
  bool _flipped = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  late Matrix4 correction;
  double angleCorrection = 0;

  @override
  void initState() {
    super.initState();

    correction = Matrix4.identity();
    if (widget._flipDirection == FlipDirection.right || widget._flipDirection == FlipDirection.left) {
      correction.rotateY(pi);
    } else if (widget._flipDirection == FlipDirection.up || widget._flipDirection == FlipDirection.down) {
      correction.rotateX(-pi);
    }
    _flipped = false;
    _controller = AnimationController(vsync: this, duration: widget._duration);
    _animation=Tween<double>(begin: 0,end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget._curve,
      ),);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> flipWidget() async {
    if(_controller.isAnimating) return false;
    _flipped = !_flipped;
    await _controller.forward(from: 0).then((value) => angleCorrection = pi);
    return _flipped;
  }

  @override
  Widget build(BuildContext context) {



    widget._controller._state = this;
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          double angle = _animation.value * pi;
          if(!_flipped){
            angle += angleCorrection;
          }
          final transformation = Matrix4.identity()
            ..setEntry(3, 2, .001);
          if (widget._flipDirection == FlipDirection.right) {
            transformation.rotateY(-angle);
          } else if (widget._flipDirection == FlipDirection.left) {
            transformation.rotateY(angle);
          } else if (widget._flipDirection == FlipDirection.up) {
            transformation.rotateX(-angle);
          } else if (widget._flipDirection == FlipDirection.down) {
            transformation.rotateX(angle);
          }

          return Transform(
            transform: transformation,
            alignment: Alignment.center,
            child: isFrontImage(angle)
                ? widget._front
                : Transform(
              transform: correction,
              alignment: Alignment.center,
              child: widget._back,
            ),
          );
        });
  }

  final degrees90 = pi / 2;
  final degress270 = 3 * pi / 2;
  bool isFrontImage(double angle) {
    angle = angle.abs();
    return angle <= degrees90 || angle >= degress270;
  }


}

class FlipperWidgetController {
  FlipperWidgetState? _state;

  Future flipWidget() async => _state?.flipWidget();
}
