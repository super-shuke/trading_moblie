import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:tradingMt1/component/common/pageContent/index.dart';

class Kline extends StatefulWidget {
  const Kline({super.key});

  @override
  State<Kline> createState() => _KlineState();
}

class _KlineState extends State<Kline> {
  List<Candle> candles = [];
  bool themeIsDark = false;

  String klineMode = '1h';

  @override
  void initState() {
    fetchCandles().then((value) {
      setState(() {
        candles = value;
      });
    });
    super.initState();
  }

  final dio = Dio();

  Future<List<Candle>> fetchCandles() async {
    final uri = Uri.parse(
      "https://api.binance.com/api/v3/klines?symbol=BTCUSDT&interval=1h",
    );
    final res = await dio.getUri(
      uri,
      options: Options(responseType: ResponseType.json),
    );
    final list = (res.data as List<dynamic>)
        .map((e) => Candle.fromJson(e))
        .toList();

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        // For Buttons and IconButtons
        colorScheme: (themeIsDark ? ThemeData.dark() : ThemeData.light())
            .colorScheme
            .copyWith(),
      ),
      debugShowCheckedModeBanner: false,

      home: PageContent(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: _klineHeader(klineMode),
          ),
        ),
        body: Center(
          child: Candlesticks(
            candles: candles,
            actions: [
              ToolBarAction(
                width: 80,
                onPressed: () {
                  // Add your action here
                },
                child: const Text(
                  'currency',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _klineHeader(String klineMode) {
  return Container(
    width: double.infinity,
    height: 60,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () {
            print('点击了 $klineMode');
          },
          child: Text(
            klineMode,
            style: TextStyle(
              fontSize: 14,
              color: const Color.fromARGB(255, 99, 99, 99),
            ),
          ),
        ),
        const Text(
          "K线图",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.edit_outlined,
            color: Color.fromRGBO(97, 97, 97, 1),
          ),
          onPressed: () {},
        ),
      ],
    ),
  );
}
