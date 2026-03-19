package com.azizgraphics.clcltr.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "orders")
data class Order(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val projectName: String = "",
    val itemsJson: String = "[]",
    val totalAmount: Double = 0.0,
    val totalQuantity: Int = 0,
    val totalSqft: Double = 0.0,
    val currency: String = "PKR",
    val createdAt: Long = System.currentTimeMillis()
)
