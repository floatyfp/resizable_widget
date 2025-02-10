import 'package:flutter/material.dart';
import 'package:resizable_widget/resizable_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resizable Widget Example',
      theme: ThemeData.dark(),
      home: const MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  var textDirection = TextDirection.rtl;

  @override
  Widget build(BuildContext context) {
    final rtl = textDirection == TextDirection.rtl;
    return Scaffold(
      appBar: AppBar(
        title: Text('Resizable Widget Example (${rtl ? 'Right-to-Left' : 'Left-to-Right'})'),
        actions: [
          IconButton(
            icon: Icon(rtl ? Icons.subdirectory_arrow_left : Icons.subdirectory_arrow_right),
            onPressed: () {
              setState(() => textDirection = rtl ? TextDirection.ltr : TextDirection.rtl);
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: textDirection,
        child: ResizableWidget(
          isHorizontalSeparator: false,
          isDisabledSmartHide: false,
          separatorColor: Colors.white12,
          separatorSize: 4,
          onResized: _printResizeInfo,
          constraints: const [
            BoxConstraints(minWidth: 100),
            null,
            null,
          ],
          children: [
            Container(
              color: Colors.green,
              child: const Center(
                child: Text('Min Width is 100', style: TextStyle(color: Colors.black)),
              ),
            ),
            ResizableWidget(
              isHorizontalSeparator: true,
              separatorColor: Colors.blue,
              separatorSize: 10,
              constraints: const [
                BoxConstraints(minHeight: 200),
                BoxConstraints(minHeight: 100, maxHeight: 250),
                null,
              ],
              children: [
                Container(
                  color: Colors.amber,
                  child: const Center(
                    child: Text('Min Height is 200', style: TextStyle(color: Colors.black)),
                  ),
                ),
                ResizableWidget(
                  constraints: const [
                    null,
                    BoxConstraints(minHeight: 150, maxHeight: 200),
                    null,
                  ],
                  children: [
                    Container(color: Colors.greenAccent),
                    Container(
                      color: Colors.yellowAccent,
                      child: const Center(
                        child: Text('Min Height is 100\nMax Height is 250', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    Container(color: Colors.redAccent),
                  ],
                  percentages: const [0.2, 0.5, 0.3],
                ),
                Container(color: Colors.redAccent),
              ],
            ),
            Container(color: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  void _printResizeInfo(List<WidgetSizeInfo> dataList) {
    // ignore: avoid_print
    // print(dataList.map((x) => '(${x.size}, ${x.percentage}%)').join(", "));
  }
}
