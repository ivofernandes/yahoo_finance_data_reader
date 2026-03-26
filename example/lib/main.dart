import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color seedColor = Color(0xFF7C4DFF);

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0B1B),
        cardTheme: CardThemeData(
          color: const Color(0xFF181828),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF121223),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const BottomSelectionWidget(),
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
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Yahoo Finance Example'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E0E1F), Color(0xFF090913)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: const [
                YahooFinanceServiceWidget(),
                DTOSearch(),
                RawSearch(),
                ReaderConfigSearch(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF131326),
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: 'Service',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered),
            label: 'DTO',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.raw_on),
            label: 'Raw',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune),
            label: 'Reader Config',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      _selectedIndex = index;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class RawSearch extends StatefulWidget {
  const RawSearch({
    super.key,
  });

  @override
  State<RawSearch> createState() => _RawSearchState();
}

class _RawSearchState extends State<RawSearch> {
  @override
  Widget build(BuildContext context) {
    String ticker = 'SOL-USD';
    YahooFinanceDailyReader yahooFinanceDataReader =
        const YahooFinanceDailyReader();

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
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  historicalData.toString(),
                  style: const TextStyle(height: 1.4),
                ),
              ),
            ),
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
    text: 'SOL-USD',
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
        const SizedBox(height: 8),
        const Text(
          'Ticker from Yahoo Finance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Example: SOL-USD',
          ),
        ),
        const SizedBox(height: 12),
        MaterialButton(
          onPressed: load,
          minWidth: 160,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Text('Load'),
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: FutureBuilder(
            future: future,
            builder: (BuildContext context,
                AsyncSnapshot<YahooFinanceResponse> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  return const Text('No data');
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
    try {
      future = const YahooFinanceDailyReader().getDailyDTOs(controller.text);
    } catch (e) {
      debugPrint('Error: $e');
      // Show snackbar with error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }

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
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('volume: ${candle.volume}'),
                Text('adjclose: ${candle.adjClose.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class YahooFinanceServiceWidget extends StatefulWidget {
  const YahooFinanceServiceWidget({super.key});

  @override
  State<YahooFinanceServiceWidget> createState() =>
      _YahooFinanceServiceWidgetState();
}

class _YahooFinanceServiceWidgetState extends State<YahooFinanceServiceWidget> {
  TextEditingController controller = TextEditingController(
    text: 'SOL-USD',
  );
  List<YahooFinanceCandleData> pricesList = [];
  List? cachedPrices;
  bool loading = true;
  bool adjust = true;
  DateTime? startDate;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    loading = true;
    setState(() {});

    try {
      // Get response for the first time
      pricesList = await YahooFinanceService().getTickerData(
        controller.text,
        startDate: startDate,
        adjust: adjust,
      );
    } catch (e) {
      debugPrint('Error: $e');
      // Show snackbar with error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }

    loading = false;
    setState(() {});
  }

  void deleteCache() async {
    loading = true;
    setState(() {});

    try {
      await YahooFinanceDAO().removeDailyData(controller.text);
      cachedPrices = await YahooFinanceDAO().getAllDailyData(controller.text);
    } catch (e) {
      debugPrint('Error: $e');
      // Show snackbar with error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }

    loading = false;
    setState(() {});
  }

  void refresh() async {
    cachedPrices = await YahooFinanceDAO().getAllDailyData(controller.text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      itemCount: pricesList.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          final List<String> tickerOptions = [
            'SOL-USD',
            'GOOG',
            'ES=F',
            'GC=F',
            'ES=F-0.5, GC=F-0.5',
            'ES=F, GC=F',
            'GOOG, AAPL',
            'AAPL',
            'AMZN',
            'BTC-USD',
          ];
          return Card(
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: tickerOptions
                          .map(
                            (option) => Container(
                              margin: const EdgeInsets.all(5),
                              child: FilledButton.tonal(
                                style: FilledButton.styleFrom(
                                  disabledBackgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  disabledForegroundColor: Colors.white,
                                ),
                                child: Text(option),
                                onPressed: controller.text == option
                                    ? null
                                    : () {
                                        setState(() {
                                          controller.text = option;
                                        });
                                        load();
                                      },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          startDate != null
                              ? 'Selected Date:\n ${DateFormat('yyyy-MM-dd').format(startDate!)}'
                              : 'No Date Selected',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != startDate) {
                              setState(() {
                                startDate = picked;
                              });
                            }
                          },
                          child: const Text(
                            'Select Date',
                          ),
                        ),
                      ],
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text('Adjust'),
                    value: adjust,
                    onChanged: (value) =>
                        setState(() => adjust = value ?? false),
                  ),
                  const Text('Ticker from yahoo finance:'),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter ticker',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton(
                        onPressed: load,
                        child: const Text('Load'),
                      ),
                      FilledButton.tonal(
                        onPressed: deleteCache,
                        child: const Text('Delete Cache'),
                      ),
                      OutlinedButton(
                        onPressed: refresh,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (pricesList.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prices in the service ${pricesList.length}'),
                        Text('First date: ${pricesList.first.date}'),
                        Text('First price: ${pricesList.first.adjClose}'),
                        Text('Last date: ${pricesList.last.date}'),
                        Text('Last price: ${pricesList.last.adjClose}'),
                        Text(
                            'Variation: ${((pricesList.last.adjClose / pricesList.first.adjClose - 1) * 100).toStringAsFixed(2)} %'),
                      ],
                    ),
                  Text('Prices in the cache ${cachedPrices?.length}'),
                  pricesList.isEmpty
                      ? const Text('No data')
                      : const SizedBox.shrink()
                ],
              ),
            ),
          );
        } else {
          final YahooFinanceCandleData candleData = pricesList[i - 1];
          return _CandleCard(
            candleData,
          );
        }
      },
    );
  }
}

class ReaderConfigSearch extends StatefulWidget {
  const ReaderConfigSearch({super.key});

  @override
  State<ReaderConfigSearch> createState() => _ReaderConfigSearchState();
}

class _ReaderConfigSearchState extends State<ReaderConfigSearch> {
  final TextEditingController tickerController = TextEditingController(
    text: 'GOOG',
  );
  final TextEditingController timeoutController = TextEditingController(
    text: '30',
  );
  final TextEditingController headerKeyController = TextEditingController(
    text: 'x-example-header',
  );
  final TextEditingController headerValueController = TextEditingController(
    text: 'reader-example',
  );

  bool useCustomDio = false;
  bool adjust = false;
  DateTime? startDate;
  late Future<YahooFinanceResponse> future;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Test YahooFinanceDailyReader with custom Dio and all reader configs.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: tickerController,
          decoration: const InputDecoration(
            labelText: 'Ticker',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: timeoutController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Timeout (seconds)',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: headerKeyController,
          decoration: const InputDecoration(
            labelText: 'Custom header key',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: headerValueController,
          decoration: const InputDecoration(
            labelText: 'Custom header value',
          ),
        ),
        CheckboxListTile(
          title: const Text('Use custom Dio with log interceptor'),
          value: useCustomDio,
          onChanged: (value) => setState(() => useCustomDio = value ?? false),
        ),
        CheckboxListTile(
          title: const Text('Adjust prices'),
          value: adjust,
          onChanged: (value) => setState(() => adjust = value ?? false),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              startDate != null
                  ? 'Start date: ${DateFormat('yyyy-MM-dd').format(startDate!)}'
                  : 'Start date: all available history',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            FilledButton.tonal(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: startDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != startDate) {
                  setState(() => startDate = picked);
                }
              },
              child: const Text('Pick start date'),
            ),
            TextButton(
              onPressed: () => setState(() => startDate = null),
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: load,
          child: const Text('Load with config'),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: FutureBuilder(
            future: future,
            builder: (BuildContext context,
                AsyncSnapshot<YahooFinanceResponse> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final YahooFinanceResponse? response = snapshot.data;
              if (response == null || response.candlesData.isEmpty) {
                return const Text('No data');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loaded candles: ${response.candlesData.length}'),
                  Text('First date: ${response.candlesData.first.date}'),
                  Text('Last date: ${response.candlesData.last.date}'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: response.candlesData.length.clamp(0, 30),
                      itemBuilder: (BuildContext context, int index) {
                        return _CandleCard(response.candlesData[index]);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void load() {
    try {
      final int timeoutSeconds =
          int.tryParse(timeoutController.text.trim()) ?? 30;

      final Map<String, dynamic> requestHeaders = {
        'content-type': 'application/json',
        'charset': 'utf-8',
        'Access-Control-Allow-Origin': '*',
      };

      final String customHeaderKey = headerKeyController.text.trim();
      if (customHeaderKey.isNotEmpty) {
        requestHeaders[customHeaderKey] = headerValueController.text.trim();
      }

      Dio? customDio;
      if (useCustomDio) {
        customDio = Dio()
          ..interceptors.add(
            LogInterceptor(
              requestBody: false,
              responseBody: false,
            ),
          );
      }

      final YahooFinanceDailyReader reader = YahooFinanceDailyReader(
        timeout: Duration(seconds: timeoutSeconds),
        headers: requestHeaders,
        dio: customDio,
      );

      future = reader.getDailyDTOs(
        tickerController.text.trim(),
        startDate: startDate,
        adjust: adjust,
      );
    } catch (e) {
      future = Future.error(e);
    }

    setState(() {});
  }
}
