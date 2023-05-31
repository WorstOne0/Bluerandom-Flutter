// Flutter Packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// Controllers
import '/controllers/bluetooth_controller.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> with SingleTickerProviderStateMixin {
  //
  late final AnimationController _controller;

  bool _isLoading = true, _isSaving = false;

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

  void showInfoEntropy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 400,
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.all(15),
        child: const Column(
          children: [
            Text(
              "Entropy",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Explicar entropia, função, etc... Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getMethod(ExtractionMethod method) {
    switch (method) {
      case ExtractionMethod.oddOrEven:
        return "Odd Or Even";
      case ExtractionMethod.oddOrEvenDifference:
        return "Odd Or Even Difference";
      case ExtractionMethod.earlyVonNeumann:
        return "Early Von Neumann";

      default:
        return "";
    }
  }

  void saveToDevice() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    setState(() {
      _isSaving = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Info
    ExtractionMethod method = ref.read(bluetoothProvider.notifier).method;
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
    List<ChartData> allThroughput = ref.read(bluetoothProvider.notifier).allThroughput;
    double maxThroughput = ref.read(bluetoothProvider.notifier).maxThroughput;
    double totalThroughput = ref.read(bluetoothProvider).totalThroughput;

    // Devices
    List<ChartData> allDevices = ref.read(bluetoothProvider.notifier).allDevices;
    double maxDevices = ref.read(bluetoothProvider.notifier).maxDevices;

    // Battery
    int batteryStart = ref.read(bluetoothProvider.notifier).batteryStart;
    int batteryEnd = ref.read(bluetoothProvider.notifier).batteryEnd;

    return WillPopScope(
      onWillPop: () async {
        ref.read(bluetoothProvider.notifier).leaveReport();

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            "Relatório",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          // actions: [
          //   IconButton(
          //     onPressed: saveToDevice,
          //     icon: _isSaving
          //         ? const SizedBox(
          //             height: 20,
          //             width: 20,
          //             child: CircularProgressIndicator(),
          //           )
          //         : const Icon(Icons.save),
          //   ),
          //   const SizedBox(width: 10)
          // ],
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
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
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
                                  "Método",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  getMethod(method),
                                  style: const TextStyle(color: Colors.grey),
                                )
                              ],
                            ),
                            const SizedBox(height: 15),
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
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Cons. Bateria",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        showInfoEntropy(context);
                                      },
                                      child: const Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "${(batteryEnd - batteryStart)}%",
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "($batteryStart% - $batteryEnd%)",
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Entropia",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showInfoEntropy(context);
                              },
                              icon: const Icon(
                                Icons.info_outline,
                                color: Colors.grey,
                              ),
                            )
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
                                  "${shannonEntropy.toStringAsFixed(3)} per byte",
                                  style: const TextStyle(color: Colors.grey),
                                )
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Shannon Entropy (bit)",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${(shannonEntropy / 8).toStringAsFixed(3)} per bit",
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
                                  minEntropy.toStringAsFixed(3),
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
                            Row(
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
                            Text(
                              "Bytes/s",
                              style: TextStyle(color: Colors.grey),
                            )
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
                            minimum: allThroughput.isNotEmpty
                                ? allThroughput.first.day
                                : DateTime.now().subtract(const Duration(days: 1)),
                            maximum: allThroughput.isNotEmpty
                                ? allThroughput.last.day
                                : DateTime.now().subtract(const Duration(days: 1)),
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
                            FastLineSeries(
                              animationDuration: 0,
                              dataSource: allThroughput,
                              xValueMapper: (ChartData data, _) => data.day,
                              yValueMapper: (ChartData data, _) => data.value,
                              color: Theme.of(context).colorScheme.primary,
                              name: "Throughput",
                              // trendlines: [
                              //   Trendline(type: TrendlineType.movingAverage, color: Colors.blue)
                              // ],
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
                                  "${totalThroughput.toStringAsFixed(2)} bytes",
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
                                  "${maxThroughput.toStringAsFixed(2)} bytes",
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
                            minimum: allDevices.isNotEmpty
                                ? allDevices.first.day
                                : DateTime.now().subtract(const Duration(days: 1)),
                            maximum: allDevices.isNotEmpty
                                ? allDevices.last.day
                                : DateTime.now().subtract(const Duration(days: 1)),
                            isVisible: true,
                            borderWidth: 0,
                            borderColor: Colors.transparent,
                            majorGridLines: const MajorGridLines(width: 0),
                            axisLine: const AxisLine(width: 0),
                          ),
                          primaryYAxis: NumericAxis(
                            visibleMinimum: 0,
                            visibleMaximum: maxDevices * 1.3,
                            minimum: 0,
                            maximum: maxDevices * 1.3,
                            interval: maxDevices > 0.5 ? maxDevices / 10 : 0.1,
                            isVisible: true,
                            borderWidth: 0,
                            borderColor: Colors.transparent,
                            // majorGridLines: MajorGridLines(width: 0),
                            // axisLine: AxisLine(width: 0),
                          ),
                          series: [
                            FastLineSeries(
                              animationDuration: 0,
                              dataSource: allDevices,
                              xValueMapper: (ChartData data, _) => data.day,
                              yValueMapper: (ChartData data, _) => data.value,
                              color: Theme.of(context).colorScheme.primary,
                              name: "Dispositivos",
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
                                  "Max de Dispositivos",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${maxDevices.toInt()}",
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
      ),
    );
  }
}
