import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        LoadingAnimationWidget.staggeredDotsWave(
          color: const Color.fromRGBO(26, 93, 26, 100),
          size: 50,
        ),
      ]),
    );
  }
}
