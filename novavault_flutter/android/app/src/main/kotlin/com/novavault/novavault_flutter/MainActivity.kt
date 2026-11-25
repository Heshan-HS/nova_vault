package com.novavault.novavault_flutter

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.hardware.biometrics.BiometricManager
import android.hardware.biometrics.BiometricPrompt
import android.net.Uri
import android.os.Build
import android.os.CancellationSignal
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.InetAddress
import java.net.ServerSocket
import java.net.URL

class MainActivity : FlutterActivity() {
    private val channelName = "com.novavault.novavault_flutter/oauth"
    private var methodChannel: MethodChannel? = null
    private var serverSocket: ServerSocket? = null
    private var pendingWebViewResult: MethodChannel.Result? = null
    private val reqCodeOAuthWebView = 9001
    private var pendingCredentialResult: MethodChannel.Result? = null
    private val reqCodeDeviceCredential = 9002

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val data = intent.data
        if (data != null && data.scheme == "com.googleusercontent.apps.838081552655-d8na33a1eb0kp6sblmeom9mp10if0a98") {
            val code = data.getQueryParameter("code")
            val error = data.getQueryParameter("error")
            Log.i("NovaVaultOAuth", "Deep link OAuth callback received")
            methodChannel?.invokeMethod(
                "onOAuthCallback",
                mapOf("code" to code, "error" to error)
            )
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == reqCodeOAuthWebView) {
            val res = pendingWebViewResult
            pendingWebViewResult = null
            if (res != null) {
                if (resultCode == RESULT_OK && data != null) {
                    res.success(
                        mapOf(
                            "code" to data.getStringExtra("code"),
                            "error" to data.getStringExtra("error")
                        )
                    )
                } else {
                    res.success(mapOf("code" to null, "error" to "Cancelled"))
                }
            }
        } else if (requestCode == reqCodeDeviceCredential) {
            val res = pendingCredentialResult
            pendingCredentialResult = null
            res?.success(resultCode == RESULT_OK)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "canAuthenticate" -> {
                    result.success(canAuthenticateDevice())
                }

                "authenticateDevice" -> {
                    val title = call.argument<String>("title") ?: "Unlock NovaVault"
                    val subtitle = call.argument<String>("subtitle") ?: "Verify with fingerprint, pattern, or PIN"
                    authenticateWithDevice(title, subtitle, result)
                }

                "startWebViewOAuth" -> {
                    val authUrl = call.argument<String>("authUrl") ?: ""
                    val redirectPrefix = call.argument<String>("redirectPrefix") ?: "http://127.0.0.1"
                    pendingWebViewResult = result
                    val intent = Intent(this, OAuthWebViewActivity::class.java).apply {
                        putExtra("authUrl", authUrl)
                        putExtra("redirectPrefix", redirectPrefix)
                    }
                    startActivityForResult(intent, reqCodeOAuthWebView)
                }

                "startOAuthServer" -> {
                    try {
                        serverSocket?.close()
                    } catch (_: Exception) {}

                    try {
                        val svcIntent = Intent(this@MainActivity, OAuthForegroundService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(svcIntent)
                        } else {
                            startService(svcIntent)
                        }
                    } catch (e: Exception) {
                        Log.w("NovaVaultOAuth", "FGS start warning: ${e.message}")
                    }

                    try {
                        val ss = ServerSocket(0, 50, InetAddress.getByName("127.0.0.1"))
                        serverSocket = ss
                        val port = ss.localPort
                        Log.i("NovaVaultOAuth", "Native ServerSocket listening on 127.0.0.1:$port")

                        Thread {
                            try {
                                while (!ss.isClosed) {
                                    val client = ss.accept()
                                    try {
                                        val reader = BufferedReader(InputStreamReader(client.getInputStream()))
                                        val requestLine = reader.readLine() ?: ""
                                        Log.i("NovaVaultOAuth", "Request: $requestLine")

                                        // Drain headers
                                        var line: String?
                                        while (reader.readLine().also { line = it } != null && line!!.isNotEmpty()) {}

                                        val parts = requestLine.split(" ")
                                        val rawPath = if (parts.size >= 2) parts[1] else "/"
                                        val parsedUri = Uri.parse("http://127.0.0.1$rawPath")

                                        if (parsedUri.path == "/oauth2callback") {
                                            val code = parsedUri.getQueryParameter("code")
                                            val error = parsedUri.getQueryParameter("error")

                                            val html = if (code != null && error == null) {
                                                "<!DOCTYPE html><html><head><meta name='viewport' content='width=device-width,initial-scale=1'><title>NovaVault</title></head>" +
                                                    "<body style='background:#051026;color:#fff;font-family:sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;margin:0;text-align:center'>" +
                                                    "<div><h2 style='color:#6FA8FF'>Connected to NovaVault</h2><p>Returning to app...</p></div>" +
                                                    "<script>setTimeout(function(){window.close();},400);</script></body></html>"
                                            } else {
                                                "<!DOCTYPE html><html><head><meta name='viewport' content='width=device-width,initial-scale=1'><title>NovaVault</title></head>" +
                                                    "<body style='background:#051026;color:#fff;font-family:sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;margin:0;text-align:center'>" +
                                                    "<div><h2 style='color:#FF6B6B'>Authorization Cancelled</h2><p>${error ?: "Please return to NovaVault."}</p></div></body></html>"
                                            }

                                            val bodyBytes = html.toByteArray(Charsets.UTF_8)
                                            val out = client.getOutputStream()
                                            val headers = "HTTP/1.1 200 OK\r\n" +
                                                "Content-Type: text/html; charset=utf-8\r\n" +
                                                "Content-Length: ${bodyBytes.size}\r\n" +
                                                "Connection: close\r\n\r\n"
                                            out.write(headers.toByteArray(Charsets.UTF_8))
                                            out.write(bodyBytes)
                                            out.flush()
                                            client.close()

                                            try { ss.close() } catch (_: Exception) {}

                                            runOnUiThread {
                                                try {
                                                    stopService(Intent(this@MainActivity, OAuthForegroundService::class.java))
                                                } catch (_: Exception) {}
                                                val bringToFront = Intent(this@MainActivity, MainActivity::class.java)
                                                bringToFront.addFlags(
                                                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                                                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                                                )
                                                startActivity(bringToFront)
                                                methodChannel?.invokeMethod(
                                                    "onOAuthCallback",
                                                    mapOf("code" to code, "error" to error)
                                                )
                                            }
                                            break
                                        } else {
                                            val out = client.getOutputStream()
                                            out.write("HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\nConnection: close\r\n\r\n".toByteArray())
                                            out.flush()
                                            client.close()
                                        }
                                    } catch (e: Exception) {
                                        Log.e("NovaVaultOAuth", "Client error: ${e.message}")
                                        try { client.close() } catch (_: Exception) {}
                                    }
                                }
                            } catch (e: Exception) {
                                Log.i("NovaVaultOAuth", "Server loop ended: ${e.message}")
                            }
                        }.start()

                        result.success(port)
                    } catch (e: Exception) {
                        result.error("SERVER_ERROR", e.message, null)
                    }
                }

                "stopOAuthServer" -> {
                    try {
                        stopService(Intent(this@MainActivity, OAuthForegroundService::class.java))
                        serverSocket?.close()
                        serverSocket = null
                    } catch (_: Exception) {}
                    result.success(true)
                }

                "nativeHttp" -> {
                    val urlStr = call.argument<String>("url") ?: ""
                    val method = call.argument<String>("method") ?: "GET"
                    val headers = call.argument<Map<String, String>>("headers") ?: emptyMap()
                    val body = call.argument<String>("body")

                    Thread {
                        var conn: HttpURLConnection? = null
                        try {
                            val url = URL(urlStr)
                            conn = url.openConnection() as HttpURLConnection
                            conn.requestMethod = if (method == "PATCH") "POST" else method
                            if (method == "PATCH") {
                                conn.setRequestProperty("X-HTTP-Method-Override", "PATCH")
                            }
                            conn.connectTimeout = 15000
                            conn.readTimeout = 15000
                            for ((k, v) in headers) {
                                conn.setRequestProperty(k, v)
                            }
                            if (body != null && (method == "POST" || method == "PATCH" || method == "PUT")) {
                                conn.doOutput = true
                                OutputStreamWriter(conn.outputStream, Charsets.UTF_8).use { it.write(body) }
                            }
                            val statusCode = conn.responseCode
                            val stream = if (statusCode in 200..299) conn.inputStream else conn.errorStream
                            val respBody = stream?.bufferedReader(Charsets.UTF_8)?.use { it.readText() } ?: ""
                            runOnUiThread {
                                result.success(mapOf("statusCode" to statusCode, "body" to respBody))
                            }
                        } catch (e: Exception) {
                            Log.e("NovaVaultOAuth", "nativeHttp error for $urlStr: ${e.message}")
                            runOnUiThread {
                                result.error("HTTP_ERROR", "${e.javaClass.simpleName}: ${e.message}", null)
                            }
                        } finally {
                            conn?.disconnect()
                        }
                    }.start()
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun canAuthenticateDevice(): Boolean {
        val km = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val bm = getSystemService(BiometricManager::class.java)
            val status = bm?.canAuthenticate(
                BiometricManager.Authenticators.BIOMETRIC_WEAK or
                    BiometricManager.Authenticators.DEVICE_CREDENTIAL
            )
            return status == BiometricManager.BIOMETRIC_SUCCESS || (km?.isDeviceSecure == true)
        }
        return km?.isDeviceSecure == true
    }

    private fun authenticateWithDevice(
        title: String,
        subtitle: String,
        result: MethodChannel.Result
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val builder = BiometricPrompt.Builder(this)
                    .setTitle(title)
                    .setSubtitle(subtitle)
                    .setAllowedAuthenticators(
                        BiometricManager.Authenticators.BIOMETRIC_WEAK or
                            BiometricManager.Authenticators.DEVICE_CREDENTIAL
                    )
                val prompt = builder.build()
                val cancelSignal = CancellationSignal()
                prompt.authenticate(
                    cancelSignal,
                    mainExecutor,
                    object : BiometricPrompt.AuthenticationCallback() {
                        override fun onAuthenticationSucceeded(res: BiometricPrompt.AuthenticationResult?) {
                            runOnUiThread { result.success(true) }
                        }

                        override fun onAuthenticationError(errorCode: Int, errString: CharSequence?) {
                            runOnUiThread { result.success(false) }
                        }

                        override fun onAuthenticationFailed() {
                            // User can retry inside the system prompt
                        }
                    }
                )
                return
            } catch (e: Exception) {
                Log.w("NovaVaultBio", "BiometricPrompt R+ fallback: ${e.message}")
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                @Suppress("DEPRECATION")
                val prompt = BiometricPrompt.Builder(this)
                    .setTitle(title)
                    .setSubtitle(subtitle)
                    .setDeviceCredentialAllowed(true)
                    .build()
                prompt.authenticate(
                    CancellationSignal(),
                    mainExecutor,
                    object : BiometricPrompt.AuthenticationCallback() {
                        override fun onAuthenticationSucceeded(res: BiometricPrompt.AuthenticationResult?) {
                            runOnUiThread { result.success(true) }
                        }

                        override fun onAuthenticationError(errorCode: Int, errString: CharSequence?) {
                            runOnUiThread { result.success(false) }
                        }
                    }
                )
                return
            } catch (e: Exception) {
                Log.w("NovaVaultBio", "BiometricPrompt Q fallback: ${e.message}")
            }
        }

        @Suppress("DEPRECATION")
        val km = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
        @Suppress("DEPRECATION")
        val intent = km?.createConfirmDeviceCredentialIntent(title, subtitle)
        if (intent != null) {
            pendingCredentialResult = result
            @Suppress("DEPRECATION")
            startActivityForResult(intent, reqCodeDeviceCredential)
        } else {
            result.success(false)
        }
    }
}
