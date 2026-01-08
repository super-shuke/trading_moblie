import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:tradingMt1/component/common/pageContent/index.dart';
import 'package:tradingMt1/l10n/app_localizations.dart';
import 'package:tradingMt1/styles/theme/app_common.dart';
import 'package:tradingMt1/styles/buttonStyle/index.dart';

class Kline extends StatefulWidget {
  const Kline({super.key});

  @override
  State<Kline> createState() => _KlineState();
}

class _KlineState extends State<Kline> {
  List<Candle> candles = [];

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
    return PageContent(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: _klineHeader(context, klineMode),
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
              child: Text(
                AppLocalizations.of(context)!.currency,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _klineHeader(BuildContext context, String klineMode) {
  final tokens = Theme.of(context).extension<AppCommon>()!;
  return Container(
    width: double.infinity,
    height: 60,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          style: CommonButtonStyle.textBtn(
            context,
          ).copyWith(padding: MaterialStateProperty.all(EdgeInsets.zero)),
          onPressed: () {
            print('点击了 $klineMode');
          },
          child: Text(
            klineMode,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
        ),
        Text(
          AppLocalizations.of(context)!.klineTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: Icon(Icons.edit_outlined, color: tokens.textSecondary),
          onPressed: () {},
        ),
      ],
    ),
  );
}
