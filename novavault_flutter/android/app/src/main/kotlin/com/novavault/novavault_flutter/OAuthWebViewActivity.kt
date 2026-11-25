package com.novavault.novavault_flutter

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.ViewGroup
import android.webkit.CookieManager
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView

class OAuthWebViewActivity : Activity() {
    private lateinit var webView: WebView

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val authUrl = intent.getStringExtra("authUrl") ?: ""
        val redirectPrefix = intent.getStringExtra("redirectPrefix") ?: "http://127.0.0.1"

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#051026"))
        }

        // Top bar
        val topBar = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(36, 90, 36, 24)
            setBackgroundColor(Color.parseColor("#051026"))
        }

        val closeBtn = TextView(this).apply {
            text = "✕"
            textSize = 20f
            setTextColor(Color.WHITE)
            setPadding(16, 8, 28, 8)
            setOnClickListener {
                setResult(RESULT_CANCELED)
                finish()
            }
        }

        val titleView = TextView(this).apply {
            text = "Sign in with Google"
            textSize = 16f
            setTextColor(Color.WHITE)
        }

        topBar.addView(closeBtn)
        topBar.addView(titleView)

        val progress = ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal).apply {
            isIndeterminate = true
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                8
            )
        }

        webView = WebView(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                0,
                1f
            )
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.userAgentString =
                "Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36"

            webViewClient = object : WebViewClient() {
                override fun onPageFinished(view: WebView?, url: String?) {
                    progress.visibility = android.view.View.GONE
                }

                override fun shouldOverrideUrlLoading(
                    view: WebView?,
                    request: WebResourceRequest?
                ): Boolean {
                    val url = request?.url?.toString() ?: return false
                    return handleUrl(url, redirectPrefix)
                }

                @Deprecated("Deprecated in Java")
                override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                    if (url == null) return false
                    return handleUrl(url, redirectPrefix)
                }
            }
        }

        CookieManager.getInstance().setAcceptCookie(true)
        CookieManager.getInstance().setAcceptThirdPartyCookies(webView, true)

        root.addView(topBar)
        root.addView(progress)
        root.addView(webView)
        setContentView(root)

        Log.i("NovaVaultOAuth", "WebView loading authUrl")
        webView.loadUrl(authUrl)
    }

    private fun handleUrl(url: String, redirectPrefix: String): Boolean {
        if (url.startsWith(redirectPrefix)) {
            Log.i("NovaVaultOAuth", "WebView intercepted callback: $url")
            val uri = Uri.parse(url)
            val code = uri.getQueryParameter("code")
            val error = uri.getQueryParameter("error")
            val resIntent = Intent().apply {
                putExtra("code", code)
                putExtra("error", error)
            }
            setResult(RESULT_OK, resIntent)
            finish()
            return true
        }
        return false
    }
}
