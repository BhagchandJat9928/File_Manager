package com.example.file_manager


import android.os.Environment
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "storage_info")
            .setMethodCallHandler { call, result ->
                if (call.method.equals("root")) {

                    val folder = File(Environment.getRootDirectory().path)
                    val allFiles: ArrayList<File> = folder.listFiles()?.asList() as ArrayList<File>
                    val paths = ArrayList<String>()
                    if (allFiles.size >= 1) {
                        for (i in 0 until allFiles.size) {
                            paths.add(allFiles[i].path)
                        }

                    }

                    if (paths.size <= 0) {
                        result.error("Empty", "No path Exist", null)
                    } else {
                        result.success(paths)
                    }

                }else if(call.method.equals("Documents")){
                   val file =File(Environment.getRootDirectory().path+"/Documents")
                  val files : ArrayList<File> = file.listFiles()?.asList() as ArrayList<File>
                    if (files.size <= 0) {
                        result.error("Empty", "No path Exist", null)
                    } else {
                        result.success(files)
                    }
                }
            }
    }
}
