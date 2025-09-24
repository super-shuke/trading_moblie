import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:tradingMt1/component/common/List/index.dart';
import 'package:tradingMt1/component/common/pageContent/index.dart';
import 'package:tradingMt1/service/index.dart';
import 'package:tradingMt1/styles/textStyle/index.dart';
import 'package:tradingMt1/utils/format.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  List<Map<String, dynamic>> list = [];
  final api = ApiService();

  Future<void> fetchPremiumIndexes() async {
    final res = await api.dioGet("/oneDayTicker.listBySymbol", [
      'BTCUSDT',
      'ETHUSDT',
    ]);
    setState(() {
      list = List<Map<String, dynamic>>.from(res);
      print(list);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPremiumIndexes();
  }

  @override
  Widget build(BuildContext context) {
    return PageContent(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: _homeWidget(),
        ),
      ),
      body: _listWidget(list),
    );
  }

  Widget _homeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.menu, color: Color.fromRGBO(97, 97, 97, 1)),
          onPressed: () {},
        ),
        const Text(
          "行情",
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
    );
  }

  Widget _listWidget(List<Map<String, dynamic>> list) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CustomList(
              itemHeight: 60,
              dataList: list,
              itemBuilder: (context, item, index) {
                return InkWell(
                  onTap: () {
                    // 处理点击事件
                    print('点击了 ${item['symbol']}');
                  },
                  splashColor: const Color.fromRGBO(214, 214, 214, .5),
                  highlightColor: Colors.grey.withOpacity(0.1),

                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              item['priceChange'].toString(),
                              style: CommonTextStyle.captionBold,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              FormatUtils.formatCount(
                                item['priceChangePercent'],
                                decimals: 2,
                                ratio: true,
                              ),
                              style: CommonTextStyle.price,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['symbol'].toString(),
                                  style: CommonTextStyle.normal,
                                ),
                                Text(
                                  FormatUtils.formatTimestamp(item['openTime']),
                                  style: CommonTextStyle.captionBold,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['lastPrice'],
                                      style: CommonTextStyle.normal,
                                    ),
                                    Text(
                                      'L: ${item['lowPrice']}',
                                      style: CommonTextStyle.captionBold,
                                    ),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      item['lastPrice'],
                                      style: CommonTextStyle.normal,
                                    ),
                                    Text(
                                      'H: ${item['highPrice']}',
                                      style: CommonTextStyle.captionBold,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
