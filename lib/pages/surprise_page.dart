import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SurprisePage extends StatefulWidget {
  const SurprisePage({super.key});

  @override
  State<SurprisePage> createState() => _SurprisePageState();
}

class Star {
  late AnimationController controller;
  late Animation<double> animation;
  late double initialX;

  Star(TickerProvider vsync, Duration duration, double screenWidth, int index) {
    final random = Random();
    initialX = random.nextDouble() * screenWidth;

    controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );

    // Adicione um atraso multiplicando o índice
    Future.delayed(Duration(seconds: index-1), () {
      controller.forward();
    });

    animation = Tween(begin: 1.0, end: -1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }
}

class _SurprisePageState extends State<SurprisePage>
    with TickerProviderStateMixin {
  late List<Star> stars;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    stars = List.generate(
      25,
      (index) => Star(
        this,
        const Duration(seconds: 3),
        MediaQuery.of(context).size.width,
        index,
      ),
    );

    // Adiciona um listener para controlar quando as estrelas chegarem ao topo
    stars.last.controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Ao chegar ao topo, exibe o texto
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/bkg_lov.jpg'), // Substitua pelo caminho da sua imagem de fundo
                fit: BoxFit.cover,
              ),
            ),
          ),
          for (var star in stars)
            AnimatedBuilder(
              animation: star.animation,
              builder: (context, child) {
                return Positioned(
                  left: star.initialX,
                  top:
                      star.animation.value * MediaQuery.of(context).size.height,
                  child: child!,
                );
              },
              child: GestureDetector(
                child: Center(
                  child: Image.asset(
                    'assets/images/heart.png', // Certifique-se de ter o arquivo star.png em sua pasta de ativos
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),
          // if (stars.isNotEmpty &&
          //     stars.last.controller.status == AnimationStatus.completed)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Querida Giovana (MINHA NAMORADA PERFEITA)\n\n\nOi, meu amor. Isso é apenas uma pequena declaração que decidi fazer. Esta página é dedicada a você, minha vida. Quero dizer que conhecer você foi a coisa mais importante da minha vida, e descobrir que você sente o mesmo por mim é ainda mais incrível. Gostaria que soubesse que te amo mais do que tudo no universo, amor. Você é a namorada mais perfeita e incrível que já existiu em todo o universo. Seus olhos, sua boca, seu cabelo, praticamente tudo relacionado a você me deixa completamente apaixonado e derretido, amor. Sou muito feliz por ter você na minha vida. Eu te amo muito, muito, muito, muito. Prometo fazer você feliz e ser seu apoio em todas as situações. Serei seu porto seguro sempre. Obrigado por existir, minha vida. EU TE AMO!!\n\n\nDo seu namorado e maior admirador.",
                  style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      backgroundColor: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var star in stars) {
      star.controller.dispose();
    }
    super.dispose();
  }
}
