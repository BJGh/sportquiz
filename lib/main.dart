import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportquiz/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await fetchRemoteConfig();
  final sharedPreferences = await SharedPreferences.getInstance();
  final savedUrl = sharedPreferences.getString('savedUrl');
  if (savedUrl != null) {
    // Open the saved URL immediately
    runApp(MyApp(initialUrl: savedUrl));
  } else {
    await fetchRemoteConfig();
    runApp(MyApp());
  }
}

Future<void> fetchRemoteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  // Add default values to Remote Config
  remoteConfig.setDefaults(<String, dynamic>{
    'url': 'https://google.com',
  });

  try {
    // Fetch remote config values and activate them
    await remoteConfig.fetchAndActivate();

    // Save the URL locally
    final sharedPreferences = await SharedPreferences.getInstance();
    final url = remoteConfig.getString('url');
    await sharedPreferences.setString('savedUrl', url);
  } catch (e) {
    // Handle any errors during fetch or activation
    print('Error fetching remote config: $e');
  }
}

class MyApp extends StatelessWidget {
  final String? initialUrl;
  //const MyApp({Key? key}) : super(key: key);
  const MyApp({Key? key, this.initialUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
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
    _webViewController.goBack();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: onBackPressed,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Container(
                width: MediaQuery.of(context)
                    .size
                    .width, // Set width to fit the entire screen
                child: Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest: URLRequest(
                          url: Uri.parse(
                              widget.initialUrl ?? 'https://bjgh.github.io/')),
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
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
