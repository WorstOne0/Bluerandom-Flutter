// Flutter Packages
import 'package:bluerandom/controllers/bluetooth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  Widget build(BuildContext context) {
    super.build(context);

    double width = MediaQuery.of(context).size.width;

    List<int> outputByte = ref.watch(bluetoothProvider).outputByte;
    List<int> lastByte = ref.watch(bluetoothProvider).lastByte;

    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Output",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "10 bytes/s",
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
                SizedBox(height: 15),
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
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 10),
                    Text(
                      "Last",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 15),
                    ...List.generate(
                      8,
                      (index) => Card(
                        elevation: 2,
                        margin: EdgeInsets.only(right: 5),
                        color: Colors.grey.shade100,
                        child: Container(
                          height: width / 15,
                          width: width / 15,
                          alignment: Alignment.center,
                          child: Text(
                            lastByte.isNotEmpty ? "${lastByte[index]}" : "-",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Graficos",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "",
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
