import 'package:flutter/material.dart';

class _PulsatingLogoState extends State<PulsatingLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: Image.asset(
        "images/alertaescolar_logo.png",
        width: widget.size,
        height: widget.size,
      ),
    );
  }
}

class PulsatingLogo extends StatefulWidget {
  final double size;

  const PulsatingLogo({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  State<PulsatingLogo> createState() => _PulsatingLogoState();
}
