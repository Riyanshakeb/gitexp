package com.azizgraphics.clcltr.util

import java.text.NumberFormat
import java.util.Locale

object CurrencyFormatter {
    private val currencySymbols = mapOf(
        "PKR" to "Rs.",
        "USD" to "$",
        "EUR" to "€",
        "GBP" to "£",
        "INR" to "₹",
        "AED" to "AED",
        "SAR" to "SAR"
    )

    fun format(amount: Double, currency: String): String {
        val nf = NumberFormat.getNumberInstance(Locale.US)
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 2
        val symbol = currencySymbols[currency] ?: currency
        return "$symbol ${nf.format(amount)}"
    }

    fun getSupportedCurrencies(): List<String> = currencySymbols.keys.toList()
}
