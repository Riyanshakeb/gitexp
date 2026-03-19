package cc.kryven.app

import android.annotation.SuppressLint
import android.app.DownloadManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Color
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import android.view.KeyEvent
import android.view.View
import android.view.WindowManager
import android.webkit.*
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout

class MainActivity : AppCompatActivity() {

    private lateinit var webView: WebView
    private lateinit var progressBar: ProgressBar
    private lateinit var swipeRefresh: SwipeRefreshLayout
    private lateinit var offlineView: LinearLayout
    private val siteUrl = "https://kryven.cc/"

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        WindowCompat.setDecorFitsSystemWindows(window, false)
        window.statusBarColor = Color.parseColor("#0f0a1a")
        window.navigationBarColor = Color.parseColor("#0f0a1a")
        WindowInsetsControllerCompat(window, window.decorView).apply {
            isAppearanceLightStatusBars = false
            isAppearanceLightNavigationBars = false
        }

        setContentView(R.layout.activity_main)

        webView = findViewById(R.id.webview)
        progressBar = findViewById(R.id.progress_bar)
        swipeRefresh = findViewById(R.id.swipe_refresh)
        offlineView = findViewById(R.id.offline_view)

        val btnRetry = findViewById<TextView>(R.id.btn_retry)
        btnRetry.setOnClickListener {
            if (isNetworkAvailable()) {
                offlineView.visibility = View.GONE
                webView.visibility = View.VISIBLE
                webView.reload()
            } else {
                Toast.makeText(this, "Still no internet connection", Toast.LENGTH_SHORT).show()
            }
        }

        setupWebView()

        swipeRefresh.setColorSchemeColors(Color.parseColor("#8b5cf6"))
        swipeRefresh.setOnRefreshListener {
            webView.reload()
        }

        if (isNetworkAvailable()) {
            webView.loadUrl(siteUrl)
        } else {
            showOffline()
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun setupWebView() {
        webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            databaseEnabled = true
            cacheMode = WebSettings.LOAD_DEFAULT
            useWideViewPort = true
            loadWithOverviewMode = true
            setSupportZoom(false)
            builtInZoomControls = false
            allowFileAccess = true
            allowContentAccess = true
            mediaPlaybackRequiresUserGesture = false
            mixedContentMode = WebSettings.MIXED_CONTENT_NEVER_ALLOW
            userAgentString = webView.settings.userAgentString + " KryvenApp/1.0"
        }

        webView.setBackgroundColor(Color.parseColor("#0f0a1a"))

        webView.webViewClient = object : WebViewClient() {
            override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
                progressBar.visibility = View.VISIBLE
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                progressBar.visibility = View.GONE
                swipeRefresh.isRefreshing = false
                injectDarkThemeCSS()
            }

            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                val url = request?.url?.toString() ?: return false
                return if (url.contains("kryven.cc")) {
                    false
                } else {
                    startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
                    true
                }
            }

            override fun onReceivedError(view: WebView?, request: WebResourceRequest?, error: WebResourceError?) {
                if (request?.isForMainFrame == true) {
                    showOffline()
                }
            }
        }

        webView.webChromeClient = object : WebChromeClient() {
            override fun onProgressChanged(view: WebView?, newProgress: Int) {
                progressBar.progress = newProgress
                if (newProgress == 100) progressBar.visibility = View.GONE
            }

            private var customView: View? = null
            private var customViewCallback: CustomViewCallback? = null

            override fun onShowCustomView(view: View?, callback: CustomViewCallback?) {
                customView = view
                customViewCallback = callback
                val container = findViewById<FrameLayout>(R.id.fullscreen_container)
                container.addView(view)
                container.visibility = View.VISIBLE
                webView.visibility = View.GONE
                window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
            }

            override fun onHideCustomView() {
                val container = findViewById<FrameLayout>(R.id.fullscreen_container)
                container.removeAllViews()
                container.visibility = View.GONE
                webView.visibility = View.VISIBLE
                window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
                customViewCallback?.onCustomViewHidden()
                customView = null
            }
        }

        webView.setDownloadListener { url, userAgent, contentDisposition, mimeType, _ ->
            try {
                val request = DownloadManager.Request(Uri.parse(url)).apply {
                    setMimeType(mimeType)
                    addRequestHeader("User-Agent", userAgent)
                    setTitle(URLUtil.guessFileName(url, contentDisposition, mimeType))
                    setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
                    setDestinationInExternalPublicDir(
                        Environment.DIRECTORY_DOWNLOADS,
                        URLUtil.guessFileName(url, contentDisposition, mimeType)
                    )
                }
                val dm = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
                dm.enqueue(request)
                Toast.makeText(this, "Downloading...", Toast.LENGTH_SHORT).show()
            } catch (e: Exception) {
                startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
            }
        }
    }

    private fun injectDarkThemeCSS() {
        val css = "body { background-color: #0f0a1a !important; }"
        webView.evaluateJavascript(
            "(function() { var s = document.createElement('style'); s.textContent = '$css'; document.head.appendChild(s); })();",
            null
        )
    }

    private fun showOffline() {
        webView.visibility = View.GONE
        offlineView.visibility = View.VISIBLE
        progressBar.visibility = View.GONE
        swipeRefresh.isRefreshing = false
    }

    private fun isNetworkAvailable(): Boolean {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = cm.activeNetwork ?: return false
        val caps = cm.getNetworkCapabilities(network) ?: return false
        return caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_BACK && webView.canGoBack()) {
            webView.goBack()
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun onResume() {
        super.onResume()
        webView.onResume()
    }

    override fun onPause() {
        webView.onPause()
        super.onPause()
    }
}
