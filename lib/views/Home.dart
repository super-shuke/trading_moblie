import 'package:flutter/material.dart';
import 'package:tradingMt1/component/layout/pageContent/index.dart';
import 'package:tradingMt1/service/index.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  int _counter = 0;
  List list = [];
  final api = ApiService();

  Future<void> fetchPremiumIndexes() async {
    final res = await api.dioGet("/premiumIndexes.list", {'limit': 10});
    setState(() {
      list = res;
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    fetchPremiumIndexes();
  }

  @override
  Widget build(BuildContext context) {
    return PageContent(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {},
            ),
            const Text(
              "行情",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: const Text('Home Page'),
    );
  }
}
