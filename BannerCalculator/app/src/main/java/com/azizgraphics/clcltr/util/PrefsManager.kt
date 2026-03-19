package com.azizgraphics.clcltr.util

import android.content.Context
import android.content.SharedPreferences

class PrefsManager(context: Context) {
    private val prefs: SharedPreferences =
        context.getSharedPreferences("banner_calc_prefs", Context.MODE_PRIVATE)

    var defaultUnit: String
        get() = prefs.getString("default_unit", "Feet") ?: "Feet"
        set(value) = prefs.edit().putString("default_unit", value).apply()

    var defaultPrice: Double
        get() = prefs.getFloat("default_price", 0f).toDouble()
        set(value) = prefs.edit().putFloat("default_price", value.toFloat()).apply()

    var themeMode: String
        get() = prefs.getString("theme_mode", "System") ?: "System"
        set(value) = prefs.edit().putString("theme_mode", value).apply()

    var currency: String
        get() = prefs.getString("currency", "PKR") ?: "PKR"
        set(value) = prefs.edit().putString("currency", value).apply()
}
