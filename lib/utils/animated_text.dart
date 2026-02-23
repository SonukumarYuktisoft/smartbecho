import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final Duration letterDelay;

  const AnimatedText({
    Key? key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 100),
    this.letterDelay = const Duration(milliseconds: 50),
  }) : super(key: key);

  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  String _displayText = '';
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _startAnimation();
  }

  @override
  void didUpdateWidget(AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _resetAnimation();
    }
  }

  void _resetAnimation() {
    _timer?.cancel();
    _currentIndex = 0;
    _displayText = '';
    _startAnimation();
  }

  void _startAnimation() {
    if (widget.text.isEmpty) return;
    
    _timer = Timer.periodic(widget.letterDelay, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayText = widget.text.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: widget.style,
    );
  }
}
