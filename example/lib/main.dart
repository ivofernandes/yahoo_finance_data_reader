import 'package:flutter/material.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    String ticker = 'GOOG';
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Example'),
          ),
          body: FutureBuilder(
            future: const YahooFinanceDailyReader().getDailyData(ticker),
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                List<dynamic> historicalData = snapshot.data!;
                return ListView.builder(
                    itemCount: historicalData.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return Container(
                          margin: const EdgeInsets.all(10),
                          child: Text(ticker),
                        );
                      }

                      Map<String, dynamic> day = historicalData[index - 1];
                      DateTime date = DateTime.fromMillisecondsSinceEpoch(
                          day['date'] * 1000);
                      return Container(
                          margin: const EdgeInsets.all(10), child: Text('''$date
open: ${day['open']}
close: ${day['close']}
high: ${day['high']}
low: ${day['low']}
adjclose: ${day['adjclose']}
                              '''));
                    });
              } else if (snapshot.hasError) {
                return Text('Error ${snapshot.error}');
              }

              return const Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                ),
              );
            },
          )),
    );
  }
}
