package com.example.sqflite_bug_sample

import android.os.Bundle
import com.tekartik.sqflite.SqflitePlugin

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain
import io.flutter.view.FlutterNativeView
import io.flutter.view.FlutterRunArguments

class MainActivity : FlutterActivity() {
    lateinit var methodChannel: MethodChannel
    lateinit var backgroundEngine: FlutterNativeView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        methodChannel = MethodChannel(flutterView, "com.example.sqflite/backgrounded").apply {
            setMethodCallHandler { methodCall, result ->
                val args = methodCall.arguments as ArrayList<*>
                val handle = args.first() as Long

                val bundlePath = FlutterMain.findAppBundlePath(applicationContext)
                val callbackInformation =
                    FlutterCallbackInformation.lookupCallbackInformation(handle)

                backgroundEngine = FlutterNativeView(applicationContext, true)
                val runArguments = FlutterRunArguments().apply {
                    this.bundlePath = bundlePath
                    entrypoint = callbackInformation.callbackName
                    libraryPath = callbackInformation.callbackLibraryPath
                }

                SqflitePlugin.registerWith(
                    backgroundEngine.pluginRegistry.registrarFor("com.tekartik.sqflite.SqflitePlugin")
                )

                backgroundEngine.runFromBundle(runArguments)
                result.success(null)
            }
        }
    }
}
