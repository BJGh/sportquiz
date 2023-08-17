import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:     MainView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class MainView extends StatefulWidget {
  MainView({Key? key}) : super(key: key);
  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late InAppWebViewController _webViewController;
  double progress = 0;

  Future<bool> onBackPressed() async {
    _webViewController.goBack();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: onBackPressed,
          child: Column(
            children: [
              Expanded(
                child: Stack(children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(url: Uri.parse('https://bjgh.github.io/')),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        useShouldOverrideUrlLoading: true,
                        javaScriptCanOpenWindowsAutomatically: true,
                      ),
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() {
                        this.progress = progress / 100;
                      });
                    },
                  ),
                  progress < 1.0
                      ? Center(
                      child: CircularProgressIndicator(
                        value: progress,
                        color: Color.fromARGB(255, 54, 244, 177),
                        strokeWidth: 2,
                      ))
                      : Container(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}