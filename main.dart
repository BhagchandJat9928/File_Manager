import 'package:file_manager/folders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'File',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'File'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> lists = [];
  MethodChannel channel = const MethodChannel("storage_info");

  @override
  void initState() {
    getList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.file_copy_outlined,
              color: Colors.blue,
            ),
            Text(widget.title),
          ],
        ),
      ),
      drawer: Drawer(
        child: drawer(),
      ),
      body: Center(),
    );
  }

  void getList() async {
    List<String> list = [];
    list.add(await getRootDirectory());
    list.add(await getInternalStorage());
    print(list.elementAt(0));
    print(list.elementAt(1));
    /* for (String data in await getStorageList()) {
      list.add(data);
    }*/
    dynamic da = await getStorageList();
    print(da.toString());
    lists = list;
  }

  Future<String> getRootDirectory() async {
    String path = "";
    try {
      path = await channel.invokeMethod("root");
    } catch (e) {
      print(e.toString());
    }
    return path;
  }

  Future<String> getInternalStorage() async {
    String path = "";
    try {
      path = await channel.invokeMethod("external");
    } catch (e) {
      print(e.toString());
    }
    return path;
  }

  Future<dynamic> getStorageList() async {
    dynamic system;
    try {
      dynamic list = await channel.invokeMethod("storagelist");
      print(list.toString());
    } catch (e) {
      print(e.toString());
    }
    return system;
  }

  Widget drawer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: lists.map<Widget>((e) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Folder(path: e)),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              margin: EdgeInsets.all(6),
              color: Colors.blue,
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(e),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
