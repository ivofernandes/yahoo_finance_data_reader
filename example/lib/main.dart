import 'package:flutter/material.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: BottomSelectionWidget(),
    );
  }
}

class BottomSelectionWidget extends StatefulWidget {
  const BottomSelectionWidget({super.key});

  @override
  State<BottomSelectionWidget> createState() => _BottomSelectionWidgetState();
}

class _BottomSelectionWidgetState extends State<BottomSelectionWidget> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yahoo Finance Example'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: _onItemSelected,
          children: [
            DTOSearch(),
            RawSearch(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemSelected,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered),
            label: 'DTO',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.raw_on),
            label: 'Raw',
          ),
        ],
      ),
    );
  }

  void _onItemSelected(int index) {
    setState(() {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      _selectedIndex = index;
    });
    print(index.toString());
  }
}

class RawSearch extends StatefulWidget {
  const RawSearch({Key? key}) : super(key: key);

  @override
  State<RawSearch> createState() => _RawSearchState();
}

class _RawSearchState extends State<RawSearch> {
  @override
  Widget build(BuildContext context) {
    String ticker = 'GOOG';
    YahooFinanceDailyReader yahooFinanceDataReader = YahooFinanceDailyReader();

    Future<Map<String, dynamic>> future =
        yahooFinanceDataReader.getDailyData(ticker);

    return FutureBuilder(
      future: future,
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) {
            return const Text('No data');
          }

          Map<String, dynamic> historicalData = snapshot.data!;
          return SingleChildScrollView(
            child: Text(historicalData.toString()),
          );
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

class DTOSearch extends StatefulWidget {
  const DTOSearch({super.key});

  @override
  State<DTOSearch> createState() => _DTOSearchState();
}

class _DTOSearchState extends State<DTOSearch> {
  final TextEditingController controller = TextEditingController(
    text: 'GOOG',
  );
  late Future<YahooFinanceResponse> future;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Ticker from yahoo finance'),
        TextField(
          controller: controller,
        ),
        MaterialButton(
          onPressed: load,
          child: Text('Load'),
          color: Theme.of(context).primaryColor,
        ),
        Expanded(
          child: FutureBuilder(
            future: future,
            builder: (BuildContext context,
                AsyncSnapshot<YahooFinanceResponse> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  return Text('No data');
                }

                YahooFinanceResponse response = snapshot.data!;
                return ListView.builder(
                    itemCount: response.candlesData.length,
                    itemBuilder: (BuildContext context, int index) {
                      YahooFinanceCandleData candle =
                          response.candlesData[index];

                      return _CandleCard(candle);
                    });
              } else {
                return const Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void load() {
    future = YahooFinanceDailyReader().getDailyDTOs(controller.text);
    setState(() {});
  }
}

class _CandleCard extends StatelessWidget {
  final YahooFinanceCandleData candle;
  const _CandleCard(this.candle);

  @override
  Widget build(BuildContext context) {
    final String date = candle.date.toIso8601String().split('T').first;

    return Card(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(date),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('open: ${candle.open.toStringAsFixed(2)}'),
                Text('close: ${candle.close.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('low: ${candle.low.toStringAsFixed(2)}'),
                Text('high: ${candle.high.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
