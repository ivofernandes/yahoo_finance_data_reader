import 'package:flutter/material.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool useProxy = false;
  DateTime? date;

  @override
  Widget build(BuildContext context) {
    String ticker = 'GOOG';
    YahooFinanceDailyReader yahooFinanceDataReader = YahooFinanceDailyReader(
        prefix: useProxy
            ? 'https://thingproxy.freeboard.io/fetch/https://'
            : 'https://');

    Future<List> future;
    if (date == null) {
      future = yahooFinanceDataReader.getDaily(ticker);
    } else {
      future = yahooFinanceDataReader.getDaily(ticker, startDate: date);
    }

    // TODO add DTO to example
    //Future<List<YahooFinanceData>> data =
    //    yahooFinanceDataReader.getDailyDTOs(ticker);

    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Example'),
          ),
          body: Column(
            children: [
              CheckboxListTile(
                value: useProxy,
                onChanged: (value) => setState(() => useProxy = !useProxy),
                title: const Text('Use proxy'),
              ),
              CheckboxListTile(
                value: date != null,
                onChanged: (value) => setState(() {
                  if (date == null) {
                    date = DateTime.now();
                  } else {
                    date = null;
                  }
                }),
                title: const Text('Just now data'),
              ),
              Expanded(
                child: Builder(
                  builder: (BuildContext context) => SizedBox(
                    child: FutureBuilder(
                      future: future,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<dynamic>> snapshot) {
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

                                Map<String, dynamic> day =
                                    historicalData[index - 1];
                                DateTime date =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        day['date'] * 1000);
                                return Container(
                                    margin: const EdgeInsets.all(10),
                                    child:
                                        Text(generateDescription(date, day)));
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
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  String generateDescription(DateTime date, Map<String, dynamic> day) {
    return '''$date
open: ${day['open']}
close: ${day['close']}
high: ${day['high']}
low: ${day['low']}
adjclose: ${day['adjclose']}
''';
  }
}
