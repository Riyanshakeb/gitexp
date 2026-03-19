package com.azizgraphics.clcltr

import android.app.Application
import androidx.appcompat.app.AppCompatDelegate
import com.azizgraphics.clcltr.data.db.AppDatabase
import com.azizgraphics.clcltr.data.repository.AppRepository
import com.azizgraphics.clcltr.util.PrefsManager

class BannerCalculatorApp : Application() {
    val database by lazy { AppDatabase.getDatabase(this) }
    val repository by lazy { AppRepository(database) }
    lateinit var prefsManager: PrefsManager

    override fun onCreate() {
        super.onCreate()
        prefsManager = PrefsManager(this)
        applyTheme(prefsManager.themeMode)
    }

    fun applyTheme(mode: String) {
        when (mode) {
            "Light" -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
            "Dark" -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
            else -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM)
        }
    }
}
