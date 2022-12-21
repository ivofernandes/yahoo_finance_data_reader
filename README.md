This project started as a migration of the pandas datareader functionality to read yahoo finance stock prices. 
In December of 2022 yahoo started to encrypt the data in the HTML, so I needed to investigate

https://github.com/pydata/pandas-datareader/blob/main/pandas_datareader/yahoo/daily.py

This lib have a strong advantage on backtesting strategies as it can give all the dataframe in yahoo finance, this means that can get daily data on futures like NQ=F and ES=F since 2000 and it goes as far as getting data from 1927 on the SP500 yahoo finance symbol ^GSPC 

![Yahoo Finance data](https://raw.githubusercontent.com/ivofernandes/yahoo_finance_data_reader/master/doc/simulator_screenshot_1.png?raw=true)

## Features

Get daily data from yahoo finance for the entire dataframe available

## Getting started


Add the dependency to your `pubspec.yaml`:
```
yahoo_finance_data_reader: ^1.0.0
```

## Usage
```dart
YahooFinanceResponse data = await yahooFinance.getDailyDTOs('GOOG');
```

## Additional information
To include in your app as a widget you can start with this future builder and debug your way until your desired result

```dart
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
```


## Like us on pub.dev
Package url:
https://pub.dev/packages/yahoo_finance_data_reader


## Instruction to publish the package to pub.dev
dart pub publish