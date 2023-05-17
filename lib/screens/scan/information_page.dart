// Flutter Packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// Screens
import '../report/report_page.dart';
// Controllers
import '/controllers/bluetooth_controller.dart';
// Utils
import '/utils/date_format.dart';

class InformationPage extends ConsumerStatefulWidget {
  const InformationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends ConsumerState<InformationPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isExtracting = false;

  String method = "Odd Or Even";

  void startExtraction() {
    ref.read(bluetoothProvider.notifier).startedExtract();
  }

  void finishExtraction() {
    ref.read(bluetoothProvider.notifier).stopExtract();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.all(60),
        title: const Text(
          "Finalizado!",
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

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportPage(),
                        ),
                      );
                    },
                    elevation: 0,
                    color: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: const Text(
                      "Gerar",
                      style: TextStyle(color: Colors.white),
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
  Widget build(BuildContext context) {
    super.build(context);

    double width = MediaQuery.of(context).size.width;

    List<int> outputByte = ref.watch(bluetoothProvider).outputByte;
    List<int> lastByte = ref.watch(bluetoothProvider).lastByte;

    int totalBits = ref.read(bluetoothProvider.notifier).totalBits;
    List<ChartData> realTimeThroughput = ref.read(bluetoothProvider.notifier).realTimeThroughput;

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
                        value: _isExtracting,
                        onChanged: (value) {
                          value ? startExtraction() : finishExtraction();

                          setState(() {
                            _isExtracting = value;
                          });
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Metodo",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _isExtracting
                            ? Text(
                                method,
                                style: const TextStyle(color: Colors.grey),
                              )
                            : GestureDetector(
                                onTap: () {
                                  SelectDialog.showModal<String>(
                                    context,
                                    label: "Selecione o Metodo",
                                    selectedValue: "",
                                    showSearchBox: false,
                                    itemBuilder: (context, item, isSelected) => Container(
                                      height: 50,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        item,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    items: [
                                      "Odd Or Even",
                                      "Odd Or Even Difference",
                                      "Early Von Neumann"
                                    ],
                                    onChange: (String selected) {
                                      if (selected == "Odd Or Even") {
                                        ref
                                            .read(bluetoothProvider.notifier)
                                            .changeMethod(ExtractionMethod.oddOrEven);
                                      }

                                      if (selected == "Odd Or Even Difference") {
                                        ref
                                            .read(bluetoothProvider.notifier)
                                            .changeMethod(ExtractionMethod.oddOrEvenDifference);
                                      }

                                      if (selected == "Early Von Neumann") {
                                        ref
                                            .read(bluetoothProvider.notifier)
                                            .changeMethod(ExtractionMethod.earlyVonNeumann);
                                      }

                                      setState(() {
                                        method = selected;
                                      });
                                    },
                                  );
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.keyboard_arrow_down),
                                    const SizedBox(width: 5),
                                    Text(method),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (_isExtracting)
                    Column(
                      children: [
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
                                style: const TextStyle(color: Colors.grey),
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
                                elevation: Theme.of(context).brightness == Brightness.light ? 2 : 4,
                                margin: const EdgeInsets.only(right: 5),
                                color: Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey.shade100
                                    : null,
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
                              const Text(
                                "Tempo",
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
                      ],
                    )
                ],
              )),
        ),
      ),
    );
  }
}
