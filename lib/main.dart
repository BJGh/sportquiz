import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportquiz/loading.dart';
import 'package:sportquiz/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  String page = await Loading.nextPage();
  runApp(
    MaterialApp(home: page == '' ? HomePage() : MyApp(initialUrl: page)),
  );
}

class MyApp extends StatelessWidget {
  final String? initialUrl;
  //const MyApp({Key? key}) : super(key: key);
  const MyApp({Key? key, this.initialUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hollywood',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainView(initialUrl: initialUrl),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainView extends StatefulWidget {
  final String? initialUrl;

  MainView({Key? key, this.initialUrl}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late InAppWebViewController _webViewController;
  double progress = 0;

  Future<bool> onBackPressed() async {
    if (await _webViewController.canGoBack()) {
      _webViewController.goBack();
      return false;
    } else {
      // Block system back button on starting page
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea( 
      child: Scaffold(
        body: WillPopScope(
          onWillPop: onBackPressed,
          child: Container(
            width: MediaQuery.of(context)
                .size
                .width, // Set width to fit the entire screen
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest:
                      URLRequest(url: Uri.parse(widget.initialUrl.toString())),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      useShouldOverrideUrlLoading: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                      javaScriptEnabled: true,
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
                          color: Color.fromARGB(255, 2, 14, 52),
                          strokeWidth: 2,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Application {
  final String json;

  Application({required this.json});

  String? getUrl() {
    final jsonMap = jsonDecode(json);
    return jsonMap['url'];
  }
}

Future<Application> receiveApplicationJson(String json) async {
  // Process the JSON and save it to the device
  final sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setString('savedJson', json);

  return Application(json: json);
}

Future<Application> getSavedApplication() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final savedJson = sharedPreferences.getString('savedJson');
  if (savedJson == null) {
    throw Exception('No saved JSON found');
  }
  return Application(json: savedJson);
}

Future<Application> getRemoteApplication() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  // Add default values to Remote Config
  remoteConfig.setDefaults(<String, dynamic>{
    'json': '{}',
  });

  try {
    // Fetch remote config values and activate them
    await remoteConfig.fetchAndActivate();

    // Parse the JSON to get the URL
    final jsonStr = remoteConfig.getString('json');
    final json = jsonDecode(jsonStr);

    return Application(json: jsonStr);
  } catch (e) {
    // Handle any errors during fetch or activation
    print('Error fetching remote config: $e');
    throw Exception('Error fetching remote config');
  }
}
