This project is a migration of the pandas functionality to read yahoo finance stock prices

https://github.com/pydata/pandas-datareader/blob/main/pandas_datareader/yahoo/daily.py


![Zoom_demo](https://github.com/ivofernandes/yahoo_finance_data_reader/blob/master/doc/simulator_screenshot_1.gif?raw=true)

## Features

Get daily data from yahoo finance for the entire dataframe available

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

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


## Like us on pub.dev
Package url:
https://pub.dev/packages/yahoo_finance_data_reader


## Instruction to publish the package to pub.dev
dart pub publish