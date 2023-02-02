package com.example.file_manager


import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.app.appsearch.StorageInfo
import android.content.Context
import android.os.Build
import android.os.Environment
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.lang.System
import java.util.ArrayList


class MainActivity: FlutterActivity() {

    @TargetApi(Build.VERSION_CODES.R)
    @RequiresApi(Build.VERSION_CODES.S)
    @SuppressLint("SuspiciousIndentation")
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "storage_info")
            .setMethodCallHandler { call, result ->
                if (call.method.equals("root")) {
                    val path: String = Environment.getRootDirectory().absolutePath


                    if (path.isEmpty()) {
                        result.error("Empty", "No path Exist", null)
                    } else {
                        result.success(path)
                    }

                }else if (call.method.equals("Documents")) {
                    val file = File(Environment.getRootDirectory().path + "/Documents")
                    val files: ArrayList<File> = file.listFiles()?.asList() as ArrayList<File>
                    if (files.size <= 0) {
                        result.error("Empty", "No path Exist", null)
                    } else {
                        result.success(files)
                    }
                } else if (call.method.equals("storagelist")) {
                   var storageManager: StorageManager= this.getSystemService(android.content.Context.STORAGE_SERVICE) as
StorageManager
                    if (Build.VERSION.SDK_INT >=Build.VERSION_CODES.N) {
                        var storageVolumeList: List<StorageVolume> = storageManager.storageVolumes
                       /* for(  sv in storageVolumeList){
                         android.util.Log.d("volume",sv)
                        }*/

                        android.util.Log.d("volumes",storageVolumeList.size.toString()+" hrll0")
/*
                        android.util.Log.d("volumes",storageVolumeList.get(0).getMediaStorageVolumeName())
                        android.util.Log.d("volumes",storageVolumeList.get(1).getMediaStorageVolumeName())
*/

                        if (storageVolumeList.size<=0) {
                            result.error("Empty", "No path Exist", null)
                        } else {
                            result.success(java.lang.System.getenv("SECONDARY_STORAGE"))
                        }
                    }else{
                        var storage= Environment.getExternalStorageDirectory().path
                        if (storage.isEmpty()) {
                            result.error("Empty", "No path Exist", null)
                        } else {
                            result.success(storage)
                        }
                    }

                } else if (call.method.equals("external")) {
                    val path: String = Environment.getExternalStorageDirectory().path
                    Log.d("EstoragePath", Environment.getExternalStorageDirectory().absolutePath)

                    if (path.isEmpty()) {
                        result.error("Empty", "No path Exist", null)
                    } else {
                        result.success(path)
                    }
                }
            }
    }
}
