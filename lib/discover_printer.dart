import 'dart:async';
import 'dart:developer' as developer;

import 'package:bonsoir/bonsoir.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:printer_app/components/searching_printer.dart';
import 'package:printer_app/scanned_wifi_item_ui.dart';
import 'package:printer_app/utils/colors.dart';
import 'package:printer_app/utils/strings.dart';

import 'database/app_database.dart';
import 'database/printer_model.dart';
import 'home.dart';

class DiscoverUi extends StatefulWidget {
  //
  final VoidCallback onAction;
  final VoidCallback onClose;

  const DiscoverUi({
    super.key,
    required this.onAction,
    required this.onClose,
  });

  @override
  State<DiscoverUi> createState() => _DiscoverUiState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
PersistentBottomSheetController? _controller;

class _DiscoverUiState extends State<DiscoverUi> {
  // This is the type of service we're looking for :
  final String _type = '_ipp._tcp';
  late BonsoirDiscovery _discovery;
  // connectivity_plus
  // List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  // final Connectivity _connectivity = Connectivity();
  bool isInternetConnected = false;
  bool isSearchingPrinter = false;
  bool isPrinterConnected = false;

  AppDatabase noteDatabase = AppDatabase.instance;

  Timer? _timer;
  final int _start = 5;

  final Set<Map<String, dynamic>> _bonsoiPrintersList = {};
  List<PrintModel> _printListDataBase = [];

  ///////
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  Future<void> _startSearchingPrinter() async {
    await _discovery.ready;
    await _discovery.start();
    // start the timer..
    startTimer();
    // If you want to listen to the discovery :
    _discovery.eventStream!.listen((event) {
      print('LISTEN ---- found : ${event.type}}');
      // `eventStream` is not null as the discovery instance is "ready" !
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        var bonsaiResult = event.service?.toJson();

        debugPrint('Service found : $bonsaiResult');

        if (bonsaiResult != null) {
          // _bonsoiPrintersList.add(bonsaiResult);
          _printListDataBase.add(PrintModel(
              title: bonsaiResult['service.name'], isConnected: false));
        }
        // Should be called when the user wants to connect to this service.
        /* event.service!.resolve(_discovery.serviceResolver); */
      } else if (event.type ==
          BonsoirDiscoveryEventType.discoveryServiceResolved) {
        debugPrint('Service resolved : ${event.service?.toJson()}');
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        debugPrint('Service lost : ${event.service?.toJson()}');
      } else if (event.type == BonsoirDiscoveryEventType.discoveryStopped) {
        debugPrint('Service stopped : ${event.service?.toJson()}');
      }
    });
  }

  void _initPrintDiscovery() {
    _discovery = BonsoirDiscovery(type: _type);
  }

  Future<void> startSearchingPrinter() async {
    if (_discovery.isReady && _discovery.isStopped) {
      await _discovery.start();
      // start the timer..
      startTimer();
    }
  }

  Future<void> _stopSearchingPrinter() async {
    // if (!_discovery.isStopped) {
    await _discovery.stop();
    // }
    setState(() {
      isSearchingPrinter = false;
    });
  }

  Future<void> _disposeSearchingPrinter() async {
    // if (!_discovery.isStopped) {
    await _discovery.stop();
    // }
  }

  void startTimer() {
    _timer = Timer(
      Duration(seconds: _start),
      () {
        debugPrint("stopped timer after $_start");
        _stopSearchingPrinter();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initPrintDiscovery();
    // initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  refreshPrinterList() {
    noteDatabase.readAll().then((printerList) {
      setState(() {
        _printListDataBase = printerList;
        if (printerList.isEmpty) {
          isPrinterConnected = true;
        } else {
          isPrinterConnected = false;
        }
      });
      // pop until home.
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => HomeWidget(
                    title: "tes hwlo",
                  )),
          (Route route) => false);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
    // release instance references.
    _disposeSearchingPrinter();
    _closeModalBottomSheet();
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
    // ignore: avoid_print
    print('Connectivity changed: $_connectionStatus');
    if (_connectionStatus[0].name == "none") {
      // no internet
      _disposeSearchingPrinter();
      _settingModalBottomSheet(context);
      setState(() {
        isInternetConnected = false;
        isSearchingPrinter = false;
      });
      // _stopSearchingPrinter();
    } else {
      print("---INTERNET--- ${_connectionStatus[0].name}");
      // connected to internet
      // clear printers list
      _bonsoiPrintersList.clear();
      _printListDataBase.clear();
      _closeModalBottomSheet();
      setState(() {
        isInternetConnected = true;
        isSearchingPrinter = true;
      });
      // searching printers.
      _startSearchingPrinter();
    }
  }

  void _settingModalBottomSheet(context) {
    _controller =
        _scaffoldKey.currentState?.showBottomSheet((BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.35,
        margin: const EdgeInsets.all(20),
        child: Stack(children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: AppColor.lightRedColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.wifi_off,
                      color: Colors.white,
                      size: 40,
                    )),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text(
                    Strings.wifiDisconnected,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
              Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Text(
                    Strings.wifiDisconnectedDescription,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  left: 30,
                  right: 30,
                ),
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColor.lightBlueColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
                    if (OpenSettingsPlus.shared is OpenSettingsPlusAndroid) {
                      (OpenSettingsPlus.shared as OpenSettingsPlusAndroid)
                          .wifi();
                    } else if (OpenSettingsPlus.shared is OpenSettingsPlusIOS) {
                      (OpenSettingsPlus.shared as OpenSettingsPlusIOS).wifi();
                    } else {
                      throw Exception('Platform not supported');
                    }
                  },
                  child: Align(
                    child: Text(
                      "Connect to WiFi",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.lightGreyColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.close),
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ]),
      );
    });
  }

  void _closeModalBottomSheet() {
    if (_controller != null) {
      _controller?.close();
      _controller = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            scrolledUnderElevation: 0.0,
            backgroundColor: Colors.transparent,
            title: Column(
              children: [
                const Text(
                  "Available Printer",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Column(
            children: [
              Visibility(
                visible: !isSearchingPrinter,
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Tap to connect to any printer",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              if (isInternetConnected)
                if (isSearchingPrinter)
                  const SearchingPrinter()
                else
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      // itemCount: _bonsoiPrintersList.length,
                      itemCount: _printListDataBase.length,
                      itemBuilder: (context, position) {
                        // var printerName =
                        //     _bonsoiPrintersList.elementAt(position)['service.name'];
                        // debugPrint("printers list : $printerName");

                        var printModel = _printListDataBase[position];

                        return ScannedWifiItemUi(
                            key: ValueKey(printModel.isConnected),
                            printModel: printModel,
                            onConnectPressed: (connectedPrinterModel) {
                              // store the printer
                              print("connect printer tapped.");
                              addUpdatedPrinterInDB(connectedPrinterModel);
                            });
                      },
                    ),
                  ),
            ],
          )),
    );
  }

  addUpdatedPrinterInDB(PrintModel printModel) {
    // setState(() {
    //   isLoading = true;
    // });
    final model = PrintModel(
      title: printModel.title,
      // number: 1,
      // content: contentController.text,
      // isFavorite: isFavorite,
      isConnected: printModel.isConnected,
      createdTime: DateTime.now(),
    );
    // if (isNewNote) {
    // noteDatabase.create(model).then((onValue) {
    noteDatabase.create(model).then((onValue) {
      print("refreshPrinterList from db");
      refreshPrinterList();
    });
    print("stored printer in db");
    // refreshNotes();
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            children: [
              pw.SizedBox(
                width: double.infinity,
                child: pw.FittedBox(
                  child: pw.Text(title, style: pw.TextStyle(font: font)),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Flexible(child: pw.FlutterLogo()),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
