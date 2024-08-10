import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_list/models/models.dart';
import 'package:fast_list/services/authentication_service.dart';
import 'package:fast_list/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // log
  Logger logger = Logger();

  // data
  final FirebaseService _firebaseService = FirebaseService();
  final AuthenticationService _authenticationService = AuthenticationService();

  User? usuario;
  List<Lista> listas = [];
  List<Item> itens = [];
  List<Sharing> compartilhadas = [];
  List<ChartData> chartData = [];

  // ui
  bool isLoading = false;
  ScaffoldMessengerState? meuScaffoldContext;

  List<Color> chartColorList = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    var dataMap = <String, double>{
      "Pendentes": listas
          .where((e) => e.doneItens > 0 && e.doneItens < e.lengthList)
          .toList()
          .length
          .toDouble(),
      "Concluidas": listas
          .where((e) => e.doneItens == e.lengthList)
          .toList()
          .length
          .toDouble(),
      "Não iniciadas":
          listas.where((e) => e.doneItens == 0).toList().length.toDouble(),
    };

    var colorList = <Color>[
      Colors.yellowAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
    ];

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            if (isLoading)
              LoadingAnimationWidget.staggeredDotsWave(
                color: const Color.fromRGBO(26, 93, 26, 100),
                size: 50,
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 120,
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Suas Listas",
                          style: TextStyle(fontSize: 12, fontFamily: 'Roboto'),
                        ),
                        Text(
                          '${listas.length}',
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Compartilhadas",
                          style: TextStyle(fontSize: 12, fontFamily: 'Roboto'),
                        ),
                        Text(
                          '${compartilhadas.length}',
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MediaQuery.of(context).size.width > 600
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            width: 600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 32,
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Suas Listas",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                PieChart(
                                  dataMap: dataMap,
                                  chartType: ChartType.ring,
                                  baseChartColor: Colors.grey[300]!,
                                  colorList: colorList,
                                  chartValuesOptions: const ChartValuesOptions(
                                    showChartValuesInPercentage: true,
                                  ),
                                  totalValue: listas.length.toDouble(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 64.0,
                              horizontal: 8.0,
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Tarefas finalizadas",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SfCartesianChart(
                                  primaryXAxis: CategoryAxis(),
                                  series: <CartesianSeries<dynamic, dynamic>>[
                                    LineSeries<ChartData, String>(
                                      dataSource: chartData,
                                      // Bind the color for all the data points from the data source
                                      pointColorMapper: (ChartData data, _) =>
                                          data.color,
                                      xValueMapper: (ChartData data, _) =>
                                          data.x,
                                      yValueMapper: (ChartData data, _) =>
                                          data.y,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 32,
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Suas Listas",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PieChart(
                                dataMap: dataMap,
                                chartType: ChartType.ring,
                                baseChartColor: Colors.grey[300]!,
                                colorList: colorList,
                                chartValuesOptions: const ChartValuesOptions(
                                  showChartValuesInPercentage: true,
                                ),
                                totalValue: listas.length.toDouble(),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 64.0,
                            horizontal: 8.0,
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Tarefas finalizadas",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                series: <CartesianSeries<dynamic, dynamic>>[
                                  LineSeries<ChartData, String>(
                                    dataSource: chartData,
                                    // Bind the color for all the data points from the data source
                                    pointColorMapper: (ChartData data, _) =>
                                        data.color,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadData() async {
    setState(() => isLoading = true);

    try {
      String email = _authenticationService.getCurrentUserEmail();

      User? usuarioEncontrado =
          await _firebaseService.listarUsuarioByEmail(email);

      if (usuarioEncontrado != null) {
        setState(() => usuario = usuarioEncontrado);

        QuerySnapshot querySnapshot =
            await _firebaseService.listarListas(usuario!.id!);

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            listas = querySnapshot.docs.map((e) {
              var data = e.data() as Map<String, dynamic>;
              return Lista(
                  id: e.id,
                  title: data['title'],
                  doneItens: data['doneItens'],
                  lengthList: data['lengthList'],
                  creatorId: usuario!.id!,
                  lastChange: data['lastChange'].toDate());
            }).toList();

            listas = listas.reversed.toList();

            var formatter = DateFormat('MMMM');
            Map<String, int> monthlyDoneItens = {};

            for (Lista l in listas) {
              var now = l.lastChange?.toLocal();
              var month = formatter.format(now!);

              // Verifica se o mês já está no mapa
              if (monthlyDoneItens.containsKey(month)) {
                // Se já estiver, adiciona os doneItens existentes
                monthlyDoneItens[month] =
                    monthlyDoneItens[month]! + l.doneItens;
              } else {
                // Se não estiver, cria uma entrada para o mês
                monthlyDoneItens[month] = l.doneItens;
              }
            }

            int index = 0;
            monthlyDoneItens.forEach((month, doneItens) {
              var cd = ChartData(month, doneItens.toDouble(),
                  chartColorList[index < chartColorList.length ? index : 0]);
              chartData.add(cd);
              index++;
            });
          });
        }

        QuerySnapshot sharedSnapshot = await _firebaseService
            .listarCompartilhamentos(usuarioEncontrado.id!);

        if (sharedSnapshot.docs.isNotEmpty) {
          setState(() {
            compartilhadas = sharedSnapshot.docs.map((e) {
              var data = e.data() as Map<String, dynamic>;
              return Sharing(
                  id: e.id,
                  creatorId: data['creatorId'],
                  guestId: usuarioEncontrado.id!,
                  listId: data['listId']);
            }).toList();
          });
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      meuScaffoldContext?.showSnackBar(const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Falha ao carregar dados.")));
    }
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
