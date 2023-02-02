import 'dart:io';

import 'package:file_manager/files.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Folder extends StatefulWidget {
  final String path;
  const Folder({Key? key, required this.path}) : super(key: key);

  @override
  State<Folder> createState() => _FolderState(path: path);
}

class _FolderState extends State<Folder> {
  List files = [];
  List<String> list = [];
  String path;
  SortBy dropdown = SortBy.name;
  _FolderState({required this.path});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    files = listStorage(path);
    list.add(path);
  }

  @override
  Widget build(BuildContext context) {
    print(list.length);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            centerTitle: true,
            title: Text("Internal "),
            actions: [sortDropDown()],
            floating: true,
            pinned: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Expanded(child: directoryNavigation()),
            ),
          ),
          sliverBody()
        ],
      ),
    );
  }

  Widget sortDropDown() {
    List<SortBy> ls = [
      SortBy.name,
      SortBy.createdAt,
      SortBy.size,
      SortBy.type,
      SortBy.lastModified
    ];
    List<String> names = [
      "Name",
      "CreatedAt",
      "Length",
      "Type",
      "LastModified"
    ];
    return DropdownButton(
      icon: const Icon(Icons.sort, color: Colors.black),
      underline: SizedBox(),
      items: ls
          .map<DropdownMenuItem<SortBy>>(
            (e) => DropdownMenuItem(
                value: e, child: Text(names.elementAt(e.index))),
          )
          .toList(),
      onChanged: (SortBy? val) {
        setState(() {
          dropdown = val!;
          files = Sort(list: files as List<Files>, sortBy: dropdown).list;
        });
      },
    );
  }

  Widget sliverBody() {
    return SliverList(
        delegate: SliverChildBuilderDelegate(childCount: files.length,
            (context, index) {
      Files fs = files.elementAt(index);
      return ListTile(
          shape: const Border.symmetric(vertical: BorderSide()),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.keyboard_control_outlined),
          ),
          leading: fs.icon,
          title: Text(
            fs.path.split("/").last,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            if (fs.isDirectory) {
              try {
                setState(() {
                  files =
                      Sort(list: listStorage(fs.path), sortBy: dropdown).list;
                });
                list.add(fs.path);
              } catch (e) {
                print(e.toString());
              }
            } else {
              File file = File(fs.path);
              file.open();
            }
          });
    }));
  }

  Widget directoryNavigation() {
    return ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: ScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
                onPressed: () {
                  if (list.length > 1) {
                    list.removeRange(index + 1, list.length);
                  } else {
                    Navigator.pop(context);
                  }
                  setState(() {
                    files = listStorage(list.elementAt(list.length - 1));
                  });
                },
                child: Text(
                  index == 0
                      ? "Internal"
                      : list.elementAt(index).split("/").last,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color:
                          index == list.length - 1 ? Colors.red : Colors.white),
                )),
          );
        },
        separatorBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back_ios_new_outlined),
          );
        },
        itemCount: list.length);
  }

  Widget body() {
    return Container(
      color: Colors.white,
      child: ListView.separated(
          itemBuilder: (context, index) {
            Files fs = files.elementAt(index);
            return ListTile(
              leading: fs.icon,
              title: Text(
                fs.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                if (fs.isDirectory) {
                  /*Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Folder(path: fs.path)));*/
                  setState(() {
                    list.add(fs.path);
                    files = listStorage(fs.path);
                  });
                } else {
                  FilePicker.platform
                      .getDirectoryPath(initialDirectory: fs.path);
                }
              },
            );
          },
          separatorBuilder: (context, index) {
            return const Divider(
              thickness: 1,
            );
          },
          itemCount: files.length),
    );
  }

  List<Files> listStorage(String path) {
    List<Files> listFiles = [];
    Directory directory = Directory(path);
    if (directory.existsSync()) {
      List<FileSystemEntity> list = directory.listSync();
      for (FileSystemEntity entity in list) {
        listFiles.add(Files(
          path: entity.path,
        ));
      }

      return Sort(list: listFiles, sortBy: dropdown).list;
    }
    return listFiles;
  }
}
