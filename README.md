This project is a migration of the pandas functionality to read yahoo finance stock prices

https://github.com/pydata/pandas-datareader/blob/main/pandas_datareader/yahoo/daily.py

This lib have a strong advantage on backtesting strategies as it can give all the dataframe in yahoo finance, this means that can get daily data on futures like NQ=F and ES=F since 2000 and it goes as far as getting data from 1927 on the SP500 yahoo finance symbol ^GSPC 

![Yahoo Finance data](https://raw.githubusercontent.com/ivofernandes/yahoo_finance_data_reader/master/doc/simulator_screenshot_1.png?raw=true)

## Features

Get daily data from yahoo finance for the entire dataframe available

## Getting started


Add the dependency to your `pubspec.yaml`:
```
yahoo_finance_data_reader: ^0.0.2
```

## Usage
```dart
List<dynamic> prices = await YahooFinanceDailyReader().getDailyData('GOOG');
```

## Additional information
To include in your app as a widget you can start with this future builder and debug your way until your desired result

```dart
FutureBuilder(
    future: const YahooFinanceDailyReader().getDailyData('GOOG'),
    builder:
        (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
        List<dynamic> historicalData = snapshot.data!;
        return ListView.builder(
            itemCount: historicalData.length,
            itemBuilder: (BuildContext context, int index) {
                return Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(historicalData[index].toString()));
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
)
```

## Use a proxy to use this project in flutter web
To use this project in flutter web and don't get the CORS error, you can use a prefix in the constructor of the data reader

```
List<dynamic> prices = 
    await YahooFinanceDailyReader(prefix: 'https://thingproxy.freeboard.io/fetch/https://').getDailyData('GOOG');
```

## Like us on pub.dev
Package url:
https://pub.dev/packages/yahoo_finance_data_reader


## Instruction to publish the package to pub.dev
dart pub publish