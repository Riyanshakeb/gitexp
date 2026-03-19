package com.azizgraphics.clcltr.data.model

import java.util.UUID

data class BannerItem(
    val id: String = UUID.randomUUID().toString(),
    var material: String = "",
    var width: Double = 0.0,
    var widthUnit: String = "Feet",
    var height: Double = 0.0,
    var heightUnit: String = "Feet",
    var quantity: Int = 1,
    var pricePerSqFt: Double = 0.0
) {
    val widthInFeet: Double
        get() = if (widthUnit == "Inches") width / 12.0 else width

    val heightInFeet: Double
        get() = if (heightUnit == "Inches") height / 12.0 else height

    val sqft: Double
        get() = widthInFeet * heightInFeet

    val totalArea: Double
        get() = sqft * quantity

    val totalPrice: Double
        get() = totalArea * pricePerSqFt

    fun dimensionDisplay(): String {
        val wFeet = widthInFeet.toInt()
        val wInches = ((widthInFeet - wFeet) * 12).toInt()
        val hFeet = heightInFeet.toInt()
        val hInches = ((heightInFeet - hFeet) * 12).toInt()
        return "${wFeet}'${wInches}\" × ${hFeet}'${hInches}\""
    }
}
