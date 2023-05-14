// Flutter Packages
import 'package:bluerandom/controllers/bluetooth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> with SingleTickerProviderStateMixin {
  //
  late final AnimationController _controller;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    asyncInit();
  }

  void asyncInit() async {
    ref.read(bluetoothProvider.notifier).generateReport();

    await Future.delayed(const Duration(seconds: 4));

    setState(() {
      _isLoading = false;
    });
  }

  void saveToDevice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.all(60),
        title: const Text(
          "Deseja salvar esse relatorio?",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          height: 110,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Extração finalizada! Gostaria de gerar um relatorio?"),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    elevation: 0,
                    color: Colors.transparent,
                    child: const Text(
                      "Não",
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    elevation: 0,
                    color: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: const Text(
                      "Salvar",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
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
    // Info
    DateTime? timeStartedExtract = ref.read(bluetoothProvider.notifier).timeStartedExtract;
    DateTime? timeFinishedExtract = ref.read(bluetoothProvider.notifier).timeFinishedExtract;
    Duration durationSinceStart = timeFinishedExtract == null
        ? Duration.zero
        : timeFinishedExtract.difference(timeStartedExtract!);
    int totalBits = ref.read(bluetoothProvider.notifier).totalBits;

    // Entropy
    double shannonEntropy = ref.read(bluetoothProvider.notifier).shannonEntropy;
    double minEntropy = ref.read(bluetoothProvider.notifier).minEntropy;

    // Throughput
    List<ChartData> realTimeThroughput = ref.read(bluetoothProvider.notifier).realTimeThroughput;
    double maxThroughput = ref.read(bluetoothProvider.notifier).maxThroughput;

    // Devices

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Relatorio",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [IconButton(onPressed: saveToDevice, icon: Icon(Icons.save)), SizedBox(width: 10)],
      ),
      body: _isLoading
          ? Center(
              child: Lottie.asset(
                "assets/lottie/report_blue.json",
                controller: _controller,
                onLoaded: (composition) {
                  _controller
                    ..duration = const Duration(seconds: 2)
                    ..repeat();
                },
                height: 250,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Informação",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Duração",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${durationSinceStart.inDays > 0 ? '${durationSinceStart.inDays}d ' : ''}${durationSinceStart.inHours.remainder(24) < 10 ? 0 : ""}${durationSinceStart.inHours.remainder(24)}:${durationSinceStart.inMinutes.remainder(60) < 10 ? 0 : ""}${durationSinceStart.inMinutes.remainder(60)}:${durationSinceStart.inSeconds.remainder(60) < 10 ? 0 : ""}${durationSinceStart.inSeconds.remainder(60)}",
                                style: const TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Bytes Gerados",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${totalBits ~/ 8} bytes",
                                style: const TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Entropy",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Shannon Entropy",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$shannonEntropy per byte",
                                style: const TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Shannon Entropy",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$shannonEntropy per bit",
                                style: const TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Min Entropy",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$minEntropy",
                                style: const TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Icon(Icons.bar_chart),
                          SizedBox(width: 10),
                          Text(
                            "Throughput",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 300,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(15, 20, 20, 15),
                      child: SfCartesianChart(
                        margin: EdgeInsets.zero,
                        borderWidth: 0,
                        borderColor: Colors.transparent,
                        plotAreaBorderWidth: 0,
                        legend: Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                          width: "100%",
                          isResponsive: true,
                          overflowMode: LegendItemOverflowMode.scroll,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        zoomPanBehavior: ZoomPanBehavior(
                          enablePinching: true,
                          enableDoubleTapZooming: true,
                        ),
                        primaryXAxis: DateTimeAxis(
                          minimum: realTimeThroughput.isNotEmpty
                              ? realTimeThroughput.first.day
                              : DateTime.now().subtract(const Duration(days: 1)),
                          maximum: realTimeThroughput.isNotEmpty
                              ? realTimeThroughput.last.day
                              : DateTime.now().subtract(const Duration(days: 1)),
                          interval: 2,
                          isVisible: true,
                          borderWidth: 0,
                          borderColor: Colors.transparent,
                          majorGridLines: const MajorGridLines(width: 0),
                          axisLine: const AxisLine(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          visibleMinimum: 0,
                          visibleMaximum: maxThroughput * 1.3,
                          minimum: 0,
                          maximum: maxThroughput * 1.3,
                          interval: maxThroughput > 0.5 ? maxThroughput / 10 : 0.1,
                          isVisible: true,
                          borderWidth: 0,
                          borderColor: Colors.transparent,
                          // majorGridLines: MajorGridLines(width: 0),
                          // axisLine: AxisLine(width: 0),
                        ),
                        series: [
                          SplineSeries(
                            animationDuration: 0,
                            dataSource: realTimeThroughput,
                            xValueMapper: (ChartData data, _) => data.day,
                            yValueMapper: (ChartData data, _) => data.value,
                            color: Theme.of(context).colorScheme.primary,
                            name: "Throughput",
                            splineType: SplineType.monotonic,
                            markerSettings: MarkerSettings(
                              color: Colors.white,
                              borderWidth: 3,
                              shape: DataMarkerType.circle,
                              isVisible: true,
                              borderColor: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Median Throughput",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$shannonEntropy",
                                style: const TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Max Throughput",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$shannonEntropy per bit",
                                style: const TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Icon(Icons.bar_chart),
                          SizedBox(width: 10),
                          Text(
                            "Dispositivos",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 300,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(15, 20, 20, 15),
                      child: SfCartesianChart(
                        margin: EdgeInsets.zero,
                        borderWidth: 0,
                        borderColor: Colors.transparent,
                        plotAreaBorderWidth: 0,
                        legend: Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                          width: "100%",
                          isResponsive: true,
                          overflowMode: LegendItemOverflowMode.scroll,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        zoomPanBehavior: ZoomPanBehavior(
                          enablePinching: true,
                          enableDoubleTapZooming: true,
                        ),
                        primaryXAxis: DateTimeAxis(
                          minimum: realTimeThroughput.isNotEmpty
                              ? realTimeThroughput.first.day
                              : DateTime.now().subtract(const Duration(days: 1)),
                          maximum: realTimeThroughput.isNotEmpty
                              ? realTimeThroughput.last.day
                              : DateTime.now().subtract(const Duration(days: 1)),
                          interval: 2,
                          isVisible: true,
                          borderWidth: 0,
                          borderColor: Colors.transparent,
                          majorGridLines: const MajorGridLines(width: 0),
                          axisLine: const AxisLine(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          visibleMinimum: 0,
                          visibleMaximum: maxThroughput * 1.3,
                          minimum: 0,
                          maximum: maxThroughput * 1.3,
                          interval: maxThroughput > 0.5 ? maxThroughput / 10 : 0.1,
                          isVisible: true,
                          borderWidth: 0,
                          borderColor: Colors.transparent,
                          // majorGridLines: MajorGridLines(width: 0),
                          // axisLine: AxisLine(width: 0),
                        ),
                        series: [
                          SplineSeries(
                            animationDuration: 0,
                            dataSource: realTimeThroughput,
                            xValueMapper: (ChartData data, _) => data.day,
                            yValueMapper: (ChartData data, _) => data.value,
                            color: Theme.of(context).colorScheme.primary,
                            name: "Throughput",
                            splineType: SplineType.monotonic,
                            markerSettings: MarkerSettings(
                              color: Colors.white,
                              borderWidth: 3,
                              shape: DataMarkerType.circle,
                              isVisible: true,
                              borderColor: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Media de Dispositivos",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$shannonEntropy",
                                style: const TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Max de Diispositivos",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$shannonEntropy per bit",
                                style: const TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}
