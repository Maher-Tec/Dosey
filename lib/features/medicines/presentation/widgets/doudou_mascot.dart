import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DoudouMascot extends StatelessWidget {
  const DoudouMascot({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Doudou, le petit compagnon de Dosey',
    child: SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/animations/doudou_bounce.json',
        fit: BoxFit.contain,
        repeat: true,
        animate: !MediaQuery.of(context).disableAnimations,
      ),
    ),
  );
}
