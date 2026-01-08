import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tradingMt1/component/common/List/index.dart';
import 'package:tradingMt1/component/common/pageContent/index.dart';
import 'package:tradingMt1/l10n/app_localizations.dart';
import 'package:tradingMt1/styles/textStyle/index.dart';
import 'package:tradingMt1/styles/theme/app_button.dart';
import 'package:tradingMt1/styles/theme/app_common.dart';
import 'package:tradingMt1/store/common/common_store.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  List<Map<String, dynamic>> priceList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final content = Theme.of(context);
    final buttonStyles = content.extension<AppButtonStyles>();
    final textCommon = AppLocalizations.of(context);
    final commonStore = CommonStoreScope.of(context);

    return PageContent(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: _homeWidget(context),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            ElevatedButton(
              style: buttonStyles!.elevated,
              onPressed: () {
                print('点击了刷新按钮');
                commonStore.toggleLightDark();
              },
              child: Text(
                textCommon!.changeTheme,
                style: content.textTheme.labelMedium,
              ),
            ),
            Expanded(child: _listWidget(priceList)),
          ],
        ),
      ),
    );
  }

  Widget _homeWidget(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.menu, color: tokens.textSecondary),
          onPressed: () {},
        ),
        Text(
          AppLocalizations.of(context)!.homeTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          icon: Icon(Icons.edit_outlined, color: tokens.textSecondary),
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
                  splashColor: Theme.of(context).splashColor,
                  highlightColor: Theme.of(context).highlightColor,

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
                              style: CommonTextStyle.captionBold(context),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              item['priceChangePercent'],
                              style: CommonTextStyle.price(context),
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
                                  style: CommonTextStyle.normal(context),
                                ),
                                Text(
                                  item['openTime'],
                                  style: CommonTextStyle.captionBold(context),
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
                                      item['buy'] ?? item['lastPrice'],
                                      style: CommonTextStyle.normal(context),
                                    ),
                                    Text(
                                      'L: ${item['lowPrice']}',
                                      style: CommonTextStyle.captionBold(
                                        context,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      item['sell'] ?? item['lastPrice'],
                                      style: CommonTextStyle.normal(context),
                                    ),
                                    Text(
                                      'H: ${item['highPrice']}',
                                      style: CommonTextStyle.captionBold(
                                        context,
                                      ),
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
