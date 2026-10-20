import 'package:flutter/material.dart';

class DoudouMascot extends StatelessWidget {
  const DoudouMascot({super.key, this.size = 120});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: size * .03,
          child: Container(
            width: size * .72,
            height: size * .16,
            decoration: BoxDecoration(
              color: const Color(0x1F8C7180),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        Positioned(top: size * .12, left: size * .12, child: _ear()),
        Positioned(top: size * .12, right: size * .12, child: _ear()),
        Container(
          width: size * .72,
          height: size * .67,
          decoration: BoxDecoration(
            color: const Color(0xFFF6CFAE),
            borderRadius: BorderRadius.circular(size * .3),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F9C6A52),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(top: size * .22, left: size * .18, child: _eye()),
              Positioned(top: size * .22, right: size * .18, child: _eye()),
              Positioned(
                top: size * .31,
                left: size * .22,
                child: Container(
                  width: size * .28,
                  height: size * .2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE9D5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: size * .07,
                        height: size * .05,
                        decoration: const BoxDecoration(
                          color: Color(0xFF72554D),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: size * .12,
                        height: size * .05,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFF72554D),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(top: size * .28, left: size * .06, child: _cheek()),
              Positioned(top: size * .28, right: size * .06, child: _cheek()),
            ],
          ),
        ),
        Positioned(
          right: size * .02,
          top: size * .03,
          child: Text(
            '✦',
            style: TextStyle(
              fontSize: size * .2,
              color: const Color(0xFFF1B34D),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _ear() => Container(
    width: size * .28,
    height: size * .28,
    decoration: BoxDecoration(
      color: const Color(0xFFF6CFAE),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3),
    ),
  );
  Widget _eye() => Container(
    width: size * .045,
    height: size * .065,
    decoration: BoxDecoration(
      color: const Color(0xFF59463F),
      borderRadius: BorderRadius.circular(10),
    ),
  );
  Widget _cheek() => Container(
    width: size * .1,
    height: size * .05,
    decoration: const BoxDecoration(
      color: Color(0xFFFFA9A9),
      shape: BoxShape.circle,
    ),
  );
}
