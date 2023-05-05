// Flutter Packages
import 'package:bluerandom/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// Controllers
import '/controllers/bluetooth_controller.dart';

class InformationPage extends ConsumerStatefulWidget {
  const InformationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends ConsumerState<InformationPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    ref.read(bluetoothProvider.notifier).startedExtract();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    double width = MediaQuery.of(context).size.width;

    List<int> outputByte = ref.watch(bluetoothProvider).outputByte;
    List<int> lastByte = ref.watch(bluetoothProvider).lastByte;

    int totalBits = ref.read(bluetoothProvider.notifier).totalBits;
    List<ChartData> chartData = ref.read(bluetoothProvider.notifier).chartData;

    DateTime? timeStartedExtract = ref.read(bluetoothProvider.notifier).timeStartedExtract;
    Duration durationSinceStart =
        timeStartedExtract == null ? Duration.zero : DateTime.now().difference(timeStartedExtract);

    double localThroughput = ref.read(bluetoothProvider.notifier).localThroughput;
    double maxThroughput = ref.read(bluetoothProvider.notifier).maxThroughput;
    double totalThroughput = ref.watch(bluetoothProvider).totalThroughput;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          SizedBox(width: 15),
                          Icon(Icons.memory),
                          SizedBox(width: 10),
                          Text(
                            "Extract ",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: true,
                        onChanged: (value) {},
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Metodo",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Odd Or Even",
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.pallet),
                            SizedBox(width: 10),
                            Text(
                              "Output",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "${localThroughput.toStringAsFixed(2)} bytes/s",
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ...List.generate(
                        8,
                        (index) => Card(
                          elevation: 2,
                          margin: EdgeInsets.zero,
                          child: Container(
                            height: width / 10,
                            width: width / 10,
                            alignment: Alignment.center,
                            child: Text(
                              outputByte.length > index ? "${outputByte[index]}" : "-",
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      const Text(
                        "Last",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 15),
                      ...List.generate(
                        8,
                        (index) => Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(right: 5),
                          color: Colors.grey.shade100,
                          child: Container(
                            height: width / 15,
                            width: width / 15,
                            alignment: Alignment.center,
                            child: Text(
                              lastByte.isNotEmpty ? "${lastByte[index]}" : "-",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: const [
                        Icon(Icons.bar_chart),
                        SizedBox(width: 10),
                        Text(
                          "Graficos",
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
                        minimum: chartData.isNotEmpty
                            ? chartData.first.day
                            : DateTime.now().subtract(const Duration(days: 1)),
                        maximum: chartData.isNotEmpty
                            ? chartData.last.day
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
                          dataSource: chartData,
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
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: const [
                        Icon(
                          FontAwesomeIcons.circleInfo,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Informações",
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tempo",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${durationSinceStart.inDays > 0 ? '${durationSinceStart.inDays}d ' : ''}${durationSinceStart.inHours.remainder(24) < 10 ? 0 : ""}${durationSinceStart.inHours.remainder(24)}:${durationSinceStart.inMinutes.remainder(60) < 10 ? 0 : ""}${durationSinceStart.inMinutes.remainder(60)}:${durationSinceStart.inSeconds.remainder(60) < 10 ? 0 : ""}${durationSinceStart.inSeconds.remainder(60)}",
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Bytes",
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
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Median Throughput",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${totalThroughput.toStringAsFixed(2)} bytes/s",
                          style: const TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Entropia",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "7.98",
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
