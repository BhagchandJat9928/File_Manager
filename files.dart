import 'dart:io';

import 'package:flutter/material.dart';

class Files {
  final String path;
  late Icon icon;
  late bool isDirectory;
  late String length;
  late String name;
  late DateTime lastModified;
  late DateTime createdAt;

  Files({
    required this.path,
  }) {
    int size = 0;
    if (FileSystemEntity.isDirectorySync(path)) {
      Directory dir = Directory(path);
      var fileStat = dir.statSync();
      size = fileStat.size;
      createdAt = fileStat.changed;
      lastModified = fileStat.modified;
      name = path.split("/").last;
      icon = const Icon(
        Icons.folder,
        color: Colors.deepOrangeAccent,
      );
      isDirectory = true;
    } else {
      File file = File(path);
      lastModified = file.lastModifiedSync();
      var fileStat = file.statSync();
      createdAt = fileStat.changed;
      name = file.path.split("/").last;
      size = file.lengthSync();
      isDirectory = false;
      getIcon();
    }

    getSize(size);
  }

  void getSize(int size) {
    if (size > 0 && size < 512) {
      length = "$size KB";
    } else if (size >= 512 && size < 1024 * 1024) {
      length = "${size / 1024} MB";
    } else if (size >= 1024 * 1024 && size < 1024 * 1024 * 1024) {
      length = "${size / (1024 * 1024)} GB";
    }
  }

  void getIcon() {
    switch (path.split(".").last) {
      case 'mp3':
        icon = const Icon(
          Icons.music_note_outlined,
          color: Colors.deepPurple,
        );
        break;
      case 'mp4':
        icon = const Icon(
          Icons.video_file_rounded,
          color: Colors.green,
        );
        break;
      case 'iso':
        icon = const Icon(
          Icons.ios_share_outlined,
          color: Colors.blueAccent,
        );
        break;
      case 'pdf':
        icon = const Icon(
          Icons.picture_as_pdf_outlined,
          color: Colors.red,
        );
        break;
      default:
        icon = const Icon(
          Icons.file_present_sharp,
        );
    }
  }
}

enum SortBy {
  name,
  lastModified,
  createdAt,
  type,
  size,
}

class Sort {
  List<Files> list;
  SortBy sortBy;
  Sort({required this.list, required this.sortBy}) {
    switch (sortBy) {
      case SortBy.name:
        sortByName();
        break;
      case SortBy.lastModified:
        sortByLastModified();
        break;
      case SortBy.createdAt:
        sortByNewDateFirst();
        break;
      case SortBy.type:
        sortByType();
        break;
      case SortBy.size:
        sortByLength();
        break;
    }
  }

  void sortByName() {
    list.sort((a, b) => a.name.compareTo(b.name));
  }

  void sortByLastModified() {
    list.sort((a, b) => a.lastModified.compareTo(b.lastModified));
  }

  void sortByNewDateFirst() {
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  void sortByLength() {
    list.sort((a, b) => a.length.compareTo(b.length));
  }

  void sortByType() {
    list.sort((a, b) {
      /* if(a.isDirectory){
        return 1;
      }else if(a.isDirectory==b.isDirectory){
        return 1;
      }*/
      return a.isDirectory && !b.isDirectory
          ? 1
          : !a.isDirectory && b.isDirectory
              ? -1
              : 0;
    });
  }
}

class SortFiles {
  static void swap(List<Files> arr, int start, int end) {
    Files temp = arr[start];
    arr[start] = arr[end];
    arr[end] = temp;
  }

  static List<Files> sort({required List<Files> arr, required SortBy sortBy}) {
    mergeSort(arr, 0, arr.length - 1, sortBy);
    return arr;
  }

  static void mergeSort(List<Files> arr, int start, int end, SortBy sortBy) {
    int res = sortBy == SortBy.name
        ? arr[start].name.compareTo(arr[end].name)
        : arr[start].lastModified.compareTo(arr[end].lastModified);
    if (end - start == 1 && res > 0) {
      swap(arr, start, end);
    }

    if (end - start > 1) {
      int mid = (start + end) ~/ 2;

      mergeSort(arr, start, mid, sortBy);
      mergeSort(arr, mid + 1, end, sortBy);
      List<Files> startArr = arr.getRange(start, mid + 1).toList();
      List<Files> endArr = arr.getRange(mid + 1, end + 1).toList();

      merge(arr, start, startArr, endArr, sortBy);
    }
  }

  static void merge(List<Files> arr, int start, List<Files> startarr,
      List<Files> endarr, SortBy sortBy) {
    int i = 0;
    int j = 0;
    int k = start;
    while (i < startarr.length && endarr.length > j) {
      int res = sortBy == SortBy.name
          ? startarr[i].name.compareTo(endarr[j].name)
          : startarr[i].lastModified.compareTo(endarr[j].lastModified);
      if (res > 0) {
        arr[k] = endarr[j];
        j++;
      } else {
        arr[k] = startarr[i];
        i++;
      }

      k++;
    }

    if (i < startarr.length) {
      while (i < startarr.length) {
        arr[k] = startarr[i];
        i++;
        k++;
      }
    }
    if (j < endarr.length) {
      while (j < endarr.length) {
        arr[k] = endarr[j];
        j++;
        k++;
      }
    }
  }
}
