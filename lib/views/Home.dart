import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(list[index]['symbol']),
                        Text(list[index]['markPrice']),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: Container(
        color: Colors.amber,
        height: 50,
        width: double.infinity,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(Colors.cyanAccent),
                overlayColor: MaterialStateProperty.all(Colors.red[300]),
              ),
              onPressed: () {},
              child: const Text(
                'data 按钮',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
