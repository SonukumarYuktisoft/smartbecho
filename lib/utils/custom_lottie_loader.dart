import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLottieLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: DotLottieLoader.fromAsset(
        "assets/lottie/inventory_loader.lottie",
        frameBuilder: (BuildContext ctx, DotLottie? dotlottie) {
          if (dotlottie != null) {
            return Lottie.memory(dotlottie.animations.values.single);
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
