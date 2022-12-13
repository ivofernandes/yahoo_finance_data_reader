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
  PageController _pageController = PageController();

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
            RawSearch(),
            DTOSearch(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemSelected,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.raw_on),
            label: 'Raw',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered),
            label: 'DTO',
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

    return Column(
      children: [
        CheckboxListTile(
          value: useProxy,
          onChanged: (value) => setState(() => useProxy = !useProxy),
          title: const Text('Use proxy'),
        ),
        CheckboxListTile(
          value: date != null,
          onChanged: (value) => setState(
            () {
              if (date == null) {
                date = DateTime.now();
              } else {
                date = null;
              }
            },
          ),
          title: const Text('Just now data'),
        ),
        Expanded(
          child: SizedBox(
            child: FutureBuilder(
              future: future,
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null) {
                    return Text('No data');
                  }

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
                          margin: const EdgeInsets.all(10),
                          child: Text(generateDescription(date, day)));
                    },
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
            ),
          ),
        ),
      ],
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
        Text('Ticker from yahoo finance'),
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
                      return Text(response.candlesData[index].toString());
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
