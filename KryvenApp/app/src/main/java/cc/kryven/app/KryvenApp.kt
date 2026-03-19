package cc.kryven.app

import android.app.Application
import androidx.appcompat.app.AppCompatDelegate

class KryvenApp : Application() {
    override fun onCreate() {
        super.onCreate()
        AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
    }
}
